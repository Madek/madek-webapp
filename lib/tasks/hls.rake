require 'shellwords'

namespace :madek do
  namespace :hls do
    desc 'Generate an fMP4 HLS package for one media entry. Development only.'
    task :generate, [:media_entry_id] => :environment do |_task, args|
      unless Rails.env.development?
        raise 'madek:hls:generate is for development. Production uses Zencoder.'
      end

      entry = MediaEntry.find(args[:media_entry_id])
      media_file = entry.media_file
      raise 'media entry has no file' unless media_file

      source = media_file.original_store_location
      raise "original is missing: #{source}" unless File.file?(source)

      probe = lambda do |stream, entry_name|
        `ffprobe -v error -select_streams #{stream} -show_entries stream=#{entry_name} -of csv=p=0 #{Shellwords.escape(source)}`.strip
      end
      height = probe.call('v:0', 'height').to_i
      rate_s = probe.call('v:0', 'r_frame_rate')
      rate = if rate_s.include?('/')
               num, den = rate_s.split('/').map(&:to_f)
               den.zero? ? 25.0 : num / den
             else
               rate_s.to_f
             end
      rate = 25.0 if rate <= 0
      gop = [(rate * 2).round, 1].max
      has_audio = probe.call('a:0', 'codec_type') == 'audio'

      rungs = [{ name: '360', height: 360, rate: '800k', max: '1200k', buf: '3200k' }]
      if height >= 580
        rungs << { name: '720', height: 720, rate: '3000k', max: '4500k', buf: '12000k' }
      end
      if height >= 720
        rungs << { name: '1080', height: 1080, rate: '6000k', max: '9000k', buf: '24000k' }
      end

      labels = ('a'..'z').take(rungs.length)
      filter = ["[0:v]split=#{rungs.length}#{labels.map { |label| "[#{label}]" }.join}"]
      rungs.each_with_index do |rung, index|
        filter << "[#{labels[index]}]scale=-2:#{rung[:height]}[v#{rung[:name]}]"
      end

      maps = []
      names = []
      bitrates = []
      rungs.each_with_index do |rung, index|
        maps += ['-map', "[v#{rung[:name]}]"]
        if has_audio
          maps += ['-map', '0:a']
          names << "v:#{index},a:#{index},name:#{rung[:name]}"
        else
          names << "v:#{index},name:#{rung[:name]}"
        end
        bitrates += [
          "-b:v:#{index}", rung[:rate],
          "-maxrate:v:#{index}", rung[:max],
          "-bufsize:v:#{index}", rung[:buf]
        ]
      end

      Dir.mktmpdir('madek-hls') do |out|
        command = [
          'ffmpeg', '-y', '-i', source,
          '-filter_complex', filter.join(';'),
          *maps,
          '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-profile:v', 'high',
          '-g', gop.to_s, '-keyint_min', gop.to_s, '-sc_threshold', '0',
          *bitrates,
          *(has_audio ? ['-c:a', 'aac', '-b:a', '128k', '-ar', '48000', '-ac', '2'] : ['-an']),
          '-f', 'hls', '-hls_time', '6', '-hls_playlist_type', 'vod', '-hls_segment_type', 'fmp4',
          '-hls_flags', 'single_file+independent_segments',
          '-var_stream_map', names.join(' '),
          '-master_pl_name', 'master.m3u8',
          '-hls_segment_filename', File.join(out, '%v.mp4'),
          File.join(out, '%v.m3u8')
        ]
        raise 'ffmpeg failed' unless system(*command)

        HlsPackage.new(media_file).import!(out)
      end
    end
  end
end
