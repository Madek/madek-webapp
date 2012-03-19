# -*- coding: utf-8 -*-
# Persona:  Petra
# Beruf:    Studentin
# Alter:    26
#
#
# == Verantwortung
# 
# Keine, sie studiert nur, hat aber noch keine Pflicht, das System zu
# verwenden.
#
# == Biograpie
#
# Internationale Erfahrungen während Schulzeit und Studium, Studentin im
# Master Fine Arts, digital native, nutzt soziale Netzwerke, wenig
# Erfahrung mit institutionellen Repositorien und Fachdatenbanken,
# Masterarbeit zum Thema "das weisse Rauschen" in Malerei, Ton und Video.
#
# == Lust
#
# - Cool, die ZHdK bietet eine innovative Plattform an und ich kann
#   meine Arbeiten dort hochspielen
#
# == Frust
#
# - Es geht ja gar nicht so einfach, wie ich anfänglich dachte. Da muss man
#   sich ja richtig Gedanken machen, bevor man loslegt.
#
# == Verhaltensweise
#
# - Petra loggt sich aus Neugier ins Medienarchiv ein, weil sie gehört
#   hat, dass dieses eine Plattform für mediales Arbeiten an der ZHdK
#   sei. In ihrer Studienvertiefung gibt es keine Weisungen, das
#   Medienarchiv für bestimmte Abläufe zu nutzen. Aber sie hat gehört,
#   dass zukünftig die Abschlussarbeiten über das Medienarchiv abgegeben
#   werden sollen.
#
# - Sie schaut sich im Medienarchiv um, ob sie dort spannende Inhalte
#   finden kann. Zuerst schaut sie, was aus ihrem Departement im
#   Medienarchiv zu finden sind. Wie sehen denn eigentlich die
#   Masterarbeiten von früheren Jahrgängen aus? Dann stöbert sie nach
#   Inhalten, die mit ihrer gegenwärtigen Abschlussarbeit zu tun
#   haben. Sie tippt ein "weiss" und erhält doch einige
#   Ergebnisse. Bei ein paar frägt sie sich: Was hat den das jetzt mit
#   weiss zu tun? Warum wird das hier angezeigt? Andere Beispiele
#   führen sie zur Ausstellung "Schwarz-weiss", die an der ZHdK zu
#   sehen war. Sie setzt erstmal ein paar Favoriten. Dann will sie
#   ihre Recherche fortsetzen und startet eine neue Suchanfrage
#   "rauschen". Keine Ergebnisse. Nun, sie erstellt ein Set mit dem
#   Titel "Weisses Rauschen". Dort legt sie die Bilder und Videos
#   rein, die sie vorhin favorisiert hat. Sie stöbert noch ein
#   weilchen im Medienarchiv und findet ein paar weitere für sie
#   interessante Beispiele, die sie ebenfalls in ihr Set legt.
#
# - Sie versucht herauszufinden, wie das angekündigte kollaborative
#   Arbeiten funktionieren soll.  Dazu lädt sie ein paar Medien, die sie
#   gerade auf dem Computer hat hoch, um zu schauen, wie es aussieht,
#   wenn eigene Medien dort sind. Sie gruppiert diese in einem
#   "Test-Set" und nimmt sich vor, das Medienarchiv beim nächsten
#   Projekt zur Verwaltung ihrer eigenen Medien zu verwenden


module Persona
  
  class Petra
    
    @@name = "Petra"
    @@lastname = "Paula"
    @@password = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        
        # PETRA'S GROUPS
        join_zhdk_group
        
        # PETRA'S RESOURCES
        create_test_set
      end
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
      Group.find_by_name("ZHdK").users << @user
    end

    def create_test_set # Test Set
      @mein_test_set = Factory(:media_set,
                               :user => @user, 
                               :meta_data_attributes => {0 => {:meta_key_id => MetaKey.find_by_label("title").id, :value => "Mein Test Set"}})
      Factory(:userpermission, 
              :media_resource => @mein_test_set, 
              :user => Persona.get(:normin), 
              :view => true, 
              :edit => false, 
              :manage => false, 
              :download => false)
      @mein_erstes_photo = Factory(:media_entry, 
                                   :user => @user, 
                                   :view => true,
                                   :media_sets => [@mein_test_set], 
                                   :meta_data_attributes => {0 => {:meta_key_id => MetaKey.find_by_label("title").id, :value => "Mein Erstes Photo (mit der neuen Nikon)"}})
    end
  end  
end
