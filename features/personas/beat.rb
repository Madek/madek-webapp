# -*- coding: utf-8 -*-
# Persona:  Beat Raktor
# Beruf:    Bildredaktor bei der Universitätszeitschrift
# Alter:    57
# ID: 150737
#
# == Verantwortung
# 
# * Sucht und verwaltet Bilder für die nächste Ausgabe der Uni-Zeitschrift.
#
# == Biograpie
#
# Beat hat ein gutes Auge für Fotografie und die Qualität von Fotos. Deshalb
# ist er Teil der Bildredaktion der Uni-Zeitschrift.
#
# Er mag Technologie nicht besonders und hätte lieber einen analogen Arbeits-
# ablauf. Weil er nicht sehr viel Zeit im Web verbringt, kennt er viele
# der gängigen Interaktionsformen nicht.
#
# Er arbeitet oft mit Fotografen zusammen, seine Position ist zwischen Foto-
# grafen und Layoutern.
#
# == Anforderungen an diese Persona
#
# - Im Hochschulmagazin gibt es 20 Artikel. Fast alle Autoren geben eine
#   Auswahl an Bilder in Medienarchivs, aus denen Beat diejenigen
#   auswählt, die aus seiner Sicht und nach Absprache mit der
#   Redakteurin ins Heft kommen. Von dieser Redakteurin werden die
#   Bilder pro Artikel in ein Set gegeben, das die interne
#   Artikelbildnummer als Titel hat.
#
# - Beat wählt pro Artikel eins bis fünf Bilder aus
#
# - Beat und die Redakteurin und weitere Mitglieder des Proktionsteams
#   nutzen einen separten Metadatenkontext, der die für sie wichtigen
#   Informationen verwaltet
#
# == Frust
#
# - Beat kann im Moment die Bilder nur einzeln aus dem Medienarchiv
#   exportieren, er würde gerne alle Bilder pro Artikel auf einmal
#   exportieren.
#
# - Beat würde gerne die Reihenfolge der Bilder pro Set von Hand per
#   drag and drop ändern können
#
# - Beat würde gerne die für ihn wichtigen Informationen aus dem
#   spezifischen Metadatenkontext auf der Übersichtsseite des Sets sehen
#
# - Beat ist manchmal ungeduldig, da sich mit dem Medienarchiv seine
#   gewohnten Abläufe verändert haben. Früher wurden Bilder über einen
#   Server geteilt, die notwendigen Infos wurden in den Filename
#   geschrieben. Er sieht nicht immer den Benefit in der Arbeit mit dem
#   Medienarchiv.
#
# == Verhaltensweise
#
# - Beat will am liebsten direkt zu den Medieneinträgen, die für ihn
#   bereitgestellt sind.
#
# - Beat muss immer mal wieder einen Überblick haben zu Bilder, die er
#   früher mal genutzt hat.
#
# - Beat teilt sich seinen Job mit einem Kollegen, der dann ebenfalls
#   auf die gemeinsamen Medieneinträge und Sets zugriff hat.
#
# - Die Verantwortlichen seiner Abteilung wollen zukünftig manche von
#   den Medieneinträgen, die Beat bearbeitet, als Beigabe zum gedruckten
#   Hochschulmagazin freischalten für die ZHdK bzw. für die
#   Öffentlichkeit.

module Persona
  
  class Beat
    
    @@name = "Beat"
    @@lastname = "Raktor"
    @@password = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        
        # LISELOTTE'S GROUPS
        join_zhdk_group
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
      @zhdk_group= Group.find_or_create_by_name("ZHdK")
      @zhdk_group.users << @user
    end
  end  
end