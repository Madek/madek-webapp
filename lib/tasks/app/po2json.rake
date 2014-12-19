namespace :app do

  namespace :i18n do

    desc 'Convert all .po files to json'
    task po2json: :environment do
      puts '[START] Converting all .po files from \
           locale/[LANG]/leihs.po to app/assets/javascripts/i18n/locale/[LANG].js'
      Po2json.create
      puts '[END] finished .po file conversion'
    end

  end
end
