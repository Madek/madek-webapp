# -*- coding: utf-8 -*-
# Persona:  Liselotte Landschaft
# Beruf:    Wissenschaftliche Mitarbeiterin im Forschungsprojekt
#           "Landschaftsvisualisierung" in der Studienvertiefung
#           Scientific Visualization
# Alter:    32
#
# User_Id:  5452
#
# == Verantwortung
# 
# Keine direkte -- sie will hauptsächlich arbeiten können, an ihren eigenen
# Forschungsinhalten.
#
# == Biograpie
#
# Liselotte arbeitet am Forschungsprojekt
# "Landschaftsvisualisierung". Hier geht es darum, bildnerischen
# Techniken bei der Visualisierung von Landschaften zu untersuchen. Die
# untersuchten Bilder stammen aus Landschaftsmalerei, Computergames,
# Architekturentwürfen usw. Alle Bilder werden nach den selben Kriterien
# untersucht, die sich Liselotte überlegt hat. Aus ihren Kriterien wurde
# ein spezifisches Vokabular im Medienarchiv erstellt.
#
# == Lust
#
# - Sie kann mit den Kollegen, die am selben Thema arbeiten, die
#   Bildmaterialien teilen
#
# - Sie kann ihren individuellen Blick auf die Bilder durch das spezielle
#   Vokabular sichtbar machen
#
# - Sie kann ihre Bestände visuell erschliessen
#
# == Frust
#
# - Sie würde gerne Informationen, die sie bereits einmal vergeben hat,
#   auch auf andere Medieneinträge übertragen.
#
# - Sie ist Poweruserin und hat hohe Ansprüche an die Usability des
#   Medienarchivs, die nicht immer erfüllt werden
#
# == Verhaltensweise
#
# - Liselotte fügt ihre recherchierten Bilder etappenweise ins
#   Medienarchiv ein. Metadaten und Zugriffsberechtigungen vergibt sie
#   gerne mit der Stapelverarbeitung. Sie nutzt das Gruppieren von ME in
#   Sets und das Ordnen der Sets untereinander. Wenn sie neue Bilder zu
#   ihrer Sammlung hinzugefügt hat, erweitert oder verändert sich ihr
#   Blick auf die bisherigen ME und deren Verschlagwortung. Sie überprüft
#   dann auch nochmal, wie sie früher z.B. bestimmte Begriffe verwendet
#   hat.
#
# - Zu dem Bildpool von Liselotte kommen partiell auch Bildsammlungen von
#   anderen Studierenden hinzu. Denn das Thema "Landschaftsvisualisierung"
#   ist ein thema tischer Schwerpunkt bei Scientific
#   Visualization. Während die Bildsammlung von Liselotte anfänglich nur
#   einem kleinen Arbeitskreis zugänglich ist, sollen sie später der
#   Hochschule zur Verfügung stehen. Insbesondere die Studienvertiefung
#   Scientific Visualization wird die Materialien dann aktiv im Unterricht
#   nutzen. An den Beispielbildern sollen dann verschiedene Strategien der
#   Landschaftsvisualiserung gezeigt werden.
#
# - Liselotte nutzt das Medienarchiv vor allem, um ihre Bilder und die,
#   die andere mit ihr teilen, zu verwalten. Da sie neben dem
#   individuellen Vokabular noch aktiv das Feld "Schlagworte" nutzt, freut
#   sie sich, wenn sie unter dem Schlagwort "Landschaft" auch noch
#   Abschlussarbeiten der Vertiefung Fotografie oder Dokumetationen der
#   Stadtlandschaft rund um das Toni-Areal.
#
# - Liselotte ist vom Fach und gibt immer wieder Feedback zum
#   User-Interface und den Interaktionsformen des Medienarchivs. Sie
#   artikuliert fundiert, was für sie hilfreiche Funktionen im
#   Medienarchiv wären.


module Persona
  
  class Liselotte
    
    @@name = "Liselotte"
    @@lastname = "Landschaft"
    @@password = "password"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        
        # LISELOTTE'S GROUPS
        join_zhdk_group

        create_media_entries_and_nest_them_to_media_sets_with_individual_contexts
        create_media_entries_with_gps
      end
    end

    def setup_dependencies 
      Persona.create :adam
    end
    
    def create_person
      @name = @@name
      @lastname = @@lastname  
      @person = Factory(:person, firstname: @name, lastname: @lastname)
    end

    def create_user
      @crypted_password = Digest::SHA1.hexdigest(@@password)
      @user = Factory(:user, :person => @person, :login => @name.downcase, :password => @crypted_password)
    end
    
    def join_zhdk_group
      @zhdk_group= Group.find_or_create_by_name("ZHdK")
      @zhdk_group.users << @user
    end
    
    def create_media_entries_and_nest_them_to_media_sets_with_individual_contexts
      landschaften_set = MediaSet.accessible_by_user(@user).detect {|x| x.title == "Landschaften" }
      zett_set = MediaSet.accessible_by_user(@user).detect {|x| x.title == "Zett" }

      media_entry = Factory(:media_entry, 
                       user: @user,
                       media_sets: [landschaften_set],
                       meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Schweizer Panorama"}})

      media_entry = Factory(:media_entry, 
                       user: @user,
                       media_sets: [landschaften_set, zett_set],
                       meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Deutsches Panorama"}})
    end

    def create_media_entries_with_gps
      media_entry = Factory(:media_entry, 
                       user: @user,
                       media_file: FactoryGirl.create(:media_file, :uploaded_data => begin
                        f = "#{Rails.root}/features/data/images/gg_gps.jpg"
                        ActionDispatch::Http::UploadedFile.new(:type=> Rack::Mime.mime_type(File.extname(f)),
                                                               :tempfile=> File.new(f, "r"),
                                                               :filename=> File.basename(f))
                       end),
                       meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: "Chinese Temple"}})
    end
    
  end  
end