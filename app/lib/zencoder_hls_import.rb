require 'fileutils'
require 'net/http'
require 'tmpdir'

# Turns the HLS outputs of one finished Zencoder job into the layout that
# HlsPackage stores (master.m3u8, 360.m3u8, 360.mp4, 360-iframe-index.m3u8, …).
#
# Without `base_url`, Zencoder temporary storage may deliver a segmented rung
# as a zip or as a playlist URL, and the master as a playlist or as a zip of
# the whole package. Each shape is detected from the downloaded bytes.
#
# A rung zip can also hold a split package (seen on fMP4 jobs): one `.m4f`,
# separate `-video-avc1`, `-audio-en-mp4a` and `-video-avc1_iframes`
# playlists, plus a per-rung multivariant playlist. Those files keep their
# role suffix and only lose the `<id>.profile_hls_<n>` prefix (`360.m4f`,
# `360-video-avc1.m3u8`, …), and the master is mapped to the new names.
class ZencoderHlsImport
  class ImportError < StandardError; end

  MASTER_LABEL = 'hls'.freeze
  RUNG_NAMES = { 'hls_360' => '360', 'hls_720' => '720', 'hls_1080' => '1080' }.freeze
  ZIP_MAGIC = "PK\x03\x04".b.freeze
  MAX_REDIRECTS = 3

  def initialize(media_file, outputs)
    @media_file = media_file
    @outputs = Array(outputs)
  end

  def call
    master = output_for(MASTER_LABEL)
    raise ImportError, 'no master playlist output' unless master
    raise ImportError, "master playlist #{master['state'] || 'unknown'}" unless finished?(master)

    Dir.mktmpdir('madek-hls') do |work|
      staging = File.join(work, 'package')
      FileUtils.mkdir_p(staging)
      master_file = download!(master['url'], File.join(work, 'master.download'))

      if zip?(master_file)
        stage_package_zip!(master_file, work, staging)
      else
        staged = stage_rungs!(work, staging)
        File.write(File.join(staging, 'master.m3u8'), rewrite_master(File.read(master_file), staged))
      end

      HlsPackage.new(@media_file).import!(staging)
    end
  end

  private

  def output_for(label)
    @outputs.find { |output| output['label'].to_s == label }
  end

  def finished?(output)
    output['state'] == 'finished'
  end

  # master zip: the whole package, as the master's own directory
  def stage_package_zip!(zip_file, work, staging)
    root = File.join(work, 'package-zip')
    extract_zip!(zip_file, root)
    master = find_master(root)
    raise ImportError, 'package zip has no master playlist' unless master

    source = File.dirname(master)
    Dir.children(source).each { |name| FileUtils.cp_r(File.join(source, name), staging) }
    return if File.basename(master) == 'master.m3u8'

    FileUtils.mv(File.join(staging, File.basename(master)), File.join(staging, 'master.m3u8'))
  end

  def find_master(root)
    playlists = Dir.glob(File.join(root, '**', '*.m3u8')).sort
    playlists.find { |path| File.basename(path) == 'master.m3u8' } ||
      playlists.find { |path| File.read(path).include?('#EXT-X-STREAM-INF') }
  end

  # Returns { '360' => { iframe: true }, … } for every rung that was staged.
  def stage_rungs!(work, staging)
    RUNG_NAMES.each_with_object({}) do |(label, name), staged|
      output = output_for(label)
      next unless output && finished?(output) && output['url'].present?

      staged[name] = stage_rung!(name, output['url'], work, staging)
    end
  end

  def stage_rung!(name, url, work, staging)
    rung_dir = File.join(work, "rung-#{name}")
    FileUtils.mkdir_p(rung_dir)
    file = download!(url, File.join(work, "#{name}.download"))

    if zip?(file)
      extract_zip!(file, rung_dir)
    else
      playlist = File.join(rung_dir, playlist_name(url, name))
      FileUtils.mv(file, playlist)
      fetch_references!(url, playlist, rung_dir)
    end

    normalize_rung!(name, rung_dir, staging)
  end

  def playlist_name(url, name)
    base = File.basename(URI.parse(url).path.to_s)
    base.end_with?('.m3u8') ? base : "#{name}.m3u8"
  rescue URI::InvalidURIError
    "#{name}.m3u8"
  end

  def fetch_references!(playlist_url, playlist_path, dir, seen = {})
    references(File.read(playlist_path)).each do |ref|
      name = basename(ref)
      next if name.empty? || seen[name]

      seen[name] = true
      dest = File.join(dir, name)
      url = resolve(playlist_url, ref)
      download!(url, dest) unless nonempty_file?(dest)
      fetch_references!(url, dest, dir, seen) if name.end_with?('.m3u8')
    end
  end

  def normalize_rung!(name, rung_dir, staging)
    playlists = Dir.glob(File.join(rung_dir, '**', '*.m3u8')).sort
    return stage_split_rung!(name, rung_dir, playlists, staging) if split_rung?(playlists)

    iframe, media = playlists.partition { |path| File.read(path).include?('#EXT-X-I-FRAMES-ONLY') }
    variant = media.find { |path| File.read(path).include?('#EXTINF') }
    raise ImportError, "rung #{name}: no media playlist" unless variant

    variant_text = File.read(variant)
    renames = media_renames(name, variant_text)
    renames.each do |source_name, target_name|
      source = find_file(rung_dir, source_name)
      raise ImportError, "rung #{name}: missing #{source_name}" unless source

      FileUtils.cp(source, File.join(staging, target_name))
    end

    File.write(File.join(staging, "#{name}.m3u8"), rewrite_references(variant_text, renames))
    if iframe.first
      File.write(File.join(staging, "#{name}-iframe-index.m3u8"),
                 rewrite_references(File.read(iframe.first), renames))
    end
    { iframe: iframe.first.present? }
  end

  def split_rung?(playlists)
    playlists.any? { |path| multivariant?(File.read(path)) }
  end

  def multivariant?(text)
    text.include?('#EXT-X-STREAM-INF') || text.include?('#EXT-X-MEDIA:')
  end

  # Returns { renames: { source basename => staged basename }, iframe: … }.
  # The per-rung multivariant playlist is dropped; the job master replaces it.
  def stage_split_rung!(name, rung_dir, playlists, staging)
    keep = Dir.glob(File.join(rung_dir, '**', '*')).select { |path| File.file?(path) }.sort
              .reject { |path| path.end_with?('.m3u8') && multivariant?(File.read(path)) }
    raise ImportError, "rung #{name}: no media playlist" if (keep & playlists).empty?

    renames = keep.to_h { |path| [File.basename(path), split_name(name, File.basename(path))] }
    if renames.values.uniq.length != renames.length
      raise ImportError, "rung #{name}: file names collide after renaming"
    end

    keep.each do |path|
      target = File.join(staging, renames.fetch(File.basename(path)))
      if path.end_with?('.m3u8')
        File.write(target, rewrite_references(File.read(path), renames))
      else
        FileUtils.cp(path, target)
      end
    end
    iframe = keep.any? { |path| path.end_with?('.m3u8') && File.read(path).include?('#EXT-X-I-FRAMES-ONLY') }
    { renames: renames, iframe: iframe, muxed: write_muxed_playlist!(name, staging, renames.values) }
  end

  # Zencoder interleaves video and audio fragments in one .m4f with a single
  # init segment for both tracks, but lists them as a video playlist plus an
  # alternate audio rendition. hls.js then feeds the two-track init segment
  # into a video-only SourceBuffer and playback fails. When every audio
  # fragment directly follows its video fragment, one playlist that loads
  # both as a single fragment plays as ordinary muxed fMP4.
  def write_muxed_playlist!(name, staging, staged_names)
    video = staged_names.find { |file| file.end_with?('.m3u8') && file.include?('-video-') && !file.include?('iframe') }
    audio = staged_names.find { |file| file.end_with?('.m3u8') && file.include?('-audio-') }
    return unless video && audio

    muxed = mux_playlists(File.read(File.join(staging, video)), File.read(File.join(staging, audio)))
    return unless muxed

    File.write(File.join(staging, "#{name}.m3u8"), muxed)
    "#{name}.m3u8"
  end

  def mux_playlists(video_text, audio_text)
    video = media_segments(video_text)
    audio = media_segments(audio_text)
    return if video.empty? || video.length != audio.length
    return unless video_text[/#EXT-X-MAP:.*/] == audio_text[/#EXT-X-MAP:.*/]

    segments = video.zip(audio).map do |v, a|
      return unless v[:uri] == a[:uri] && v[:offset] + v[:length] == a[:offset]

      v.merge(length: v[:length] + a[:length])
    end

    header = video_text.lines.take_while { |line| !line.start_with?('#EXTINF') }.join
    body = segments.map do |segment|
      "#EXTINF:#{segment[:duration]},\n#EXT-X-BYTERANGE:#{segment[:length]}@#{segment[:offset]}\n#{segment[:uri]}\n"
    end
    "#{header}#{body.join}#EXT-X-ENDLIST\n"
  end

  def media_segments(text)
    segments = []
    current = nil
    text.each_line do |line|
      stripped = line.strip
      if stripped.start_with?('#EXTINF:')
        current = { duration: stripped.delete_prefix('#EXTINF:').delete_suffix(',') }
      elsif current && (range = stripped.match(/\A#EXT-X-BYTERANGE:(\d+)@(\d+)\z/))
        current[:length] = range[1].to_i
        current[:offset] = range[2].to_i
      elsif current && !stripped.empty? && !stripped.start_with?('#')
        return [] unless current[:length]

        segments << current.merge(uri: stripped)
        current = nil
      end
    end
    segments
  end

  def split_name(name, base)
    label = RUNG_NAMES.key(name)
    renamed = base.sub(/\A.*?(?:\A|[._])#{Regexp.escape(label)}(?=\z|[-_.])/, name)
    renamed == base ? "#{name}-#{base}" : renamed
  end

  def media_renames(name, playlist_text)
    media = references(playlist_text).map { |ref| basename(ref) }
                                     .reject { |ref| ref.empty? || ref.end_with?('.m3u8') }
    raise ImportError, "rung #{name}: playlist names no media file" if media.empty?
    return { media.first => "#{name}.mp4" } if media.one?

    media.each_with_index.to_h { |ref, index| [ref, format('%<name>s-%<index>05d.m4f', name: name, index: index)] }
  end

  def find_file(root, name)
    Dir.glob(File.join(root, '**', name)).find { |path| File.file?(path) }
  end

  def rewrite_master(text, staged)
    raise ImportError, 'no rung was imported' if staged.empty?

    lines = text.lines.map(&:chomp)
    out = []
    index = 0
    while index < lines.length
      line = lines[index]
      stripped = line.strip
      if stripped.start_with?('#EXT-X-STREAM-INF')
        uri_index = next_uri_index(lines, index + 1)
        uri = uri_index && lines[uri_index].strip
        name = uri && rung_for(uri)
        if name && (muxed = staged.dig(name, :muxed))
          out.push(line.sub(/,AUDIO="[^"]*"/, ''), muxed)
        elsif name && staged[name]
          out.push(line, staged_name(staged, name, uri, "#{name}.m3u8"))
        end
        index = (uri_index || index) + 1
        next
      elsif stripped.start_with?('#EXT-X-I-FRAME-STREAM-INF')
        uri = stripped[/URI="([^"]+)"/, 1]
        name = uri && rung_for(uri)
        if name && staged.dig(name, :iframe)
          target = staged_name(staged, name, uri, "#{name}-iframe-index.m3u8")
          out << line.sub(/URI="[^"]+"/, %(URI="#{target}"))
        end
      elsif stripped.start_with?('#EXT-X-MEDIA:') && (uri = stripped[/URI="([^"]+)"/, 1])
        name = rung_for(uri)
        if name.nil?
          out << line
        elsif staged.dig(name, :muxed)
          nil
        elsif staged.dig(name, :renames)&.key?(basename(uri))
          out << line.sub(/URI="[^"]+"/, %(URI="#{staged[name][:renames][basename(uri)]}"))
        end
      else
        out << line
      end
      index += 1
    end

    unless out.any? { |line| line.strip.start_with?('#EXT-X-STREAM-INF') }
      raise ImportError, 'master lists none of the imported rungs'
    end
    "#{out.join("\n")}\n"
  end

  def staged_name(staged, name, uri, default)
    renames = staged.dig(name, :renames)
    return default unless renames

    renames.fetch(basename(uri)) { raise ImportError, "rung #{name}: master names missing #{basename(uri)}" }
  end

  def next_uri_index(lines, from)
    (from...lines.length).find do |index|
      stripped = lines[index].strip
      !stripped.empty? && !stripped.start_with?('#')
    end
  end

  def rung_for(uri)
    stem = File.basename(basename(uri), '.m3u8')
    RUNG_NAMES.each do |label, name|
      return name if stem.match?(/\A#{name}(?:\z|-)/) || stem.match?(/(?:\A|[._])#{label}(?:\z|[-_.])/)
    end
    nil
  end

  def references(text)
    refs = text.scan(/URI="([^"]+)"/).flatten
    text.each_line do |line|
      stripped = line.strip
      refs << stripped unless stripped.empty? || stripped.start_with?('#')
    end
    refs.uniq
  end

  def rewrite_references(text, renames)
    text = text.gsub(/URI="([^"]+)"/) do
      ref = ::Regexp.last_match(1)
      %(URI="#{renames.fetch(basename(ref), basename(ref))}")
    end
    text.each_line.map do |line|
      stripped = line.strip
      if stripped.empty? || stripped.start_with?('#')
        line.end_with?("\n") ? line : "#{line}\n"
      else
        "#{renames.fetch(basename(stripped), basename(stripped))}\n"
      end
    end.join
  end

  def basename(ref)
    File.basename(ref.to_s.split('?').first.to_s)
  end

  def resolve(base_url, ref)
    return ref if ref.match?(%r{\Ahttps?://}i)

    base = URI.parse(base_url)
    query = base.query
    base.query = nil
    resolved = URI.join(base.to_s, ref)
    resolved.query = query if resolved.query.nil? && query.present?
    resolved.to_s
  end

  def download!(url, target, redirects = 0)
    uri = URI.parse(url.to_s)
    raise ImportError, "unsupported url #{strip_query(url)}" unless uri.is_a?(URI::HTTP)

    FileUtils.mkdir_p(File.dirname(target))
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(Net::HTTP::Get.new(uri)) do |response|
        if response.is_a?(Net::HTTPRedirection) && response['location'] && redirects < MAX_REDIRECTS
          return download!(URI.join(url, response['location']).to_s, target, redirects + 1)
        end
        raise ImportError, "download #{response.code} #{strip_query(url)}" unless response.is_a?(Net::HTTPSuccess)

        File.open(target, 'wb') { |file| response.read_body { |chunk| file.write(chunk) } }
      end
    end
    raise ImportError, "empty download #{strip_query(url)}" unless nonempty_file?(target)

    target
  end

  def strip_query(url)
    url.to_s.split('?').first
  end

  def zip?(path)
    File.open(path, 'rb') { |file| file.read(4) } == ZIP_MAGIC
  end

  def extract_zip!(zip_path, dir)
    require 'zip'
    FileUtils.mkdir_p(dir)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        next if entry.directory?

        name = entry.name.sub(%r{\A/+}, '')
        raise ImportError, 'unsafe zip entry' if name.empty? || name.split('/').include?('..')

        entry.extract(name, destination_directory: dir, create_parent_directories: true) { true }
      end
    end
  end

  def nonempty_file?(path)
    File.file?(path) && File.size(path).positive?
  end
end
