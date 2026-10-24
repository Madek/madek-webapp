require 'open3'
require 'tmpdir'

# Development stand-in for Zencoder: builds the fMP4 HLS ladder with ffmpeg and
# stores it through HlsPackage. Optionally also writes the 620px `mp4` preview,
# so the MP4/HLS format bar has both formats to offer.
class LocalHlsEncoder
  class EncodeError < StandardError; end

  RUNGS = [
    { name: '360', height: 360, min_source_height: 0, rate: '800k', max: '1200k', buf: '3200k' },
    { name: '720', height: 720, min_source_height: 580, rate: '3000k', max: '4500k', buf: '12000k' },
    { name: '1080', height: 1080, min_source_height: 720, rate: '6000k', max: '9000k', buf: '24000k' }
  ].freeze
  PROGRESSIVE_WIDTH = 620

  def self.available?
    %w[ffmpeg ffprobe].all? { |tool| system('which', tool, out: File::NULL, err: File::NULL) }
  end

  def initialize(media_file, progressive: false)
    @media_file = media_file
    @progressive = progressive
  end

  def call
    raise EncodeError, 'ffmpeg/ffprobe not found' unless self.class.available?
    raise EncodeError, "original is missing: #{source}" unless File.file?(source)

    encode_progressive! if @progressive && @media_file.previews.where(conversion_profile: 'mp4').none?
    Dir.mktmpdir('madek-hls') do |out|
      run!(hls_command(out))
      HlsPackage.new(@media_file).import!(out)
    end
  end

  private

  def source
    @media_file.original_store_location
  end

  def probe(stream, entry)
    stdout, _status = Open3.capture2(
      'ffprobe', '-v', 'error', '-select_streams', stream,
      '-show_entries', "stream=#{entry}", '-of', 'csv=p=0', source
    )
    stdout.lines.first.to_s.strip
  end

  def source_height
    @source_height ||= probe('v:0', 'height').to_i
  end

  def gop
    rate_s = probe('v:0', 'r_frame_rate')
    num, den = rate_s.split('/').map(&:to_f)
    rate = den.to_f.zero? ? num.to_f : num / den
    rate = 25.0 unless rate.positive?
    [(rate * 2).round, 1].max
  end

  def audio?
    @audio = (probe('a:0', 'codec_type') == 'audio') if @audio.nil?
    @audio
  end

  def rungs
    RUNGS.select { |rung| source_height >= rung[:min_source_height] }
  end

  def hls_command(out)
    labels = ('a'..'z').take(rungs.length)
    filter = ["[0:v]split=#{rungs.length}#{labels.map { |label| "[#{label}]" }.join}"]
    maps = []
    names = []
    bitrates = []
    rungs.each_with_index do |rung, index|
      filter << "[#{labels[index]}]scale=-2:#{rung[:height]}[v#{rung[:name]}]"
      maps += ['-map', "[v#{rung[:name]}]"]
      maps += ['-map', '0:a:0'] if audio?
      names << (audio? ? "v:#{index},a:#{index},name:#{rung[:name]}" : "v:#{index},name:#{rung[:name]}")
      bitrates += ["-b:v:#{index}", rung[:rate], "-maxrate:v:#{index}", rung[:max], "-bufsize:v:#{index}", rung[:buf]]
    end

    [
      'ffmpeg', '-y', '-v', 'error', '-i', source,
      '-filter_complex', filter.join(';'),
      *maps,
      '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-profile:v', 'high',
      '-g', gop.to_s, '-keyint_min', gop.to_s, '-sc_threshold', '0',
      *bitrates,
      *audio_args,
      '-f', 'hls', '-hls_time', '6', '-hls_playlist_type', 'vod', '-hls_segment_type', 'fmp4',
      '-hls_flags', 'single_file+independent_segments',
      '-var_stream_map', names.join(' '),
      '-master_pl_name', 'master.m3u8',
      '-hls_segment_filename', File.join(out, '%v.mp4'),
      File.join(out, '%v.m3u8')
    ]
  end

  def audio_args
    audio? ? ['-c:a', 'aac', '-b:a', '128k', '-ar', '48000', '-ac', '2'] : ['-an']
  end

  def encode_progressive!
    target = "#{@media_file.thumbnail_store_location}_#{PROGRESSIVE_WIDTH}.mp4"
    FileUtils.mkdir_p(File.dirname(target))
    run!([
      'ffmpeg', '-y', '-v', 'error', '-i', source,
      '-vf', "scale=#{PROGRESSIVE_WIDTH}:-2",
      '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-profile:v', 'high',
      *audio_args, '-movflags', '+faststart', target
    ])
    width, height = output_size(target)
    @media_file.previews.create!(
      content_type: 'video/mp4',
      media_type: 'video',
      filename: File.basename(target),
      width: width,
      height: height,
      thumbnail: 'large',
      conversion_profile: 'mp4'
    )
  end

  def output_size(path)
    stdout, _status = Open3.capture2(
      'ffprobe', '-v', 'error', '-select_streams', 'v:0',
      '-show_entries', 'stream=width,height', '-of', 'csv=p=0', path
    )
    stdout.strip.split(',').map(&:to_i)
  end

  def run!(command)
    _stdout, stderr, status = Open3.capture3(*command)
    return if status.success?

    raise EncodeError, "ffmpeg failed: #{stderr.lines.last(5).join.strip}"
  end
end
