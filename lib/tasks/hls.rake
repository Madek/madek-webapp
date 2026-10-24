namespace :madek do
  namespace :hls do
    desc 'Generate an fMP4 HLS package for one media entry with ffmpeg. Development only.'
    task :generate, [:media_entry_id] => :environment do |_task, args|
      unless Rails.env.development?
        raise 'madek:hls:generate is for development. Production uses Zencoder.'
      end

      entry = MediaEntry.find(args[:media_entry_id])
      media_file = entry.media_file
      raise 'media entry has no file' unless media_file

      LocalHlsEncoder.new(media_file, progressive: ENV['PROGRESSIVE'].present?).call
      puts "HLS package stored in #{HlsPackage.new(media_file).dir}"
    end
  end
end
