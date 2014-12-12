class Po2json
  def self.create
    Dir.glob(Rails.root.join 'locale/**/*.po').each do |path|
      lang = path.reverse.split('/')[1].reverse
      output_path = Rails.root.join "app/assets/javascripts/i18n/locale/#{lang.gsub(/_/, '-')}.js"
      base_path = Rails.root.join "app/assets/javascripts/i18n/formats/#{lang.gsub(/_/, '-')}.js"
      Rails.logger.debug "node #{Rails.root.join 'app/node/po2json.js'} #{path} #{output_path} #{base_path}"
      `node app/node/po2json.js #{path} #{output_path} #{base_path}`
    end
  end
end
