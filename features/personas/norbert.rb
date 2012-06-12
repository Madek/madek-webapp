# -*- coding: utf-8 -*-
# Persona:  Norbert Neuerfassung
# Beruf:    Zuständiger, der Abschlussarbeiten betreut. 
#           Ausserhalb der ZHdK: Jung-Galerist in Winterthur
# Alter:    37
#
# User_Id:  164737
#
# == Verantwortung
# 
# In seiner Abteilung zuständig für die Archivierung der Abschlussarbeiten.
#
# == Biograpie
#
# Norbert hat schon mit Datenbank und digitalen Archiven im Bereich der
# Kunst gearbeitet. Da er eine Affinität zu solchen Systemen hat, wurde er
# in der Vertiefung mit der Archivierung der Abschlussarbeiten über das
# Medienarchiv betraut.
#
# == Lust
#
# - Arbeitet gerne systematisch, freut sich, wenn alles seine Ordnung
#   hat und die Abschlussarbeiten übersichtlich abgelegt sind
#
# == Frust
#
# - Er kann seine inhaltliche Sicht auf die Arbeiten nicht abbilden im
#   Medienarchiv. So hat er Schwierigkeiten, eine Unterscheidung
#   zwischen Autor/in und Medienersteller/in zu treffen. Das ist doch
#   in der Kunst dasselbe!
#
# - Er arbeitet gerne zu hause und ist extrem frustiert, dass es dort
#   mit dem Import von grossen Dateien nicht richtig funktioniert und
#   das System sich überhaupt nur sehr langsam bedienen lässt.
#
# - Er bedauert, dass man im Medienarchiv die Websites und die
#   Flash-Animationen nicht sehen kann. Versteht aber, warum das so
#   ist. (RCA: Welche Websites sind gemeint?)
#
# == Verhaltensweise
#
# - Pro Semester hat Norbert die Abschlussarbeiten von ca. 15 Studierende
#   zu bearbeiten. Diese Abschlussarbeiten bestehen aus je einem Set mit
#   verschiedenen Medieneinträgen. Sie werden entweder von den Studis ins
#   Medienarchiv geladen oder von ihm importiert. Die Studis weissen ihm
#   ihre ME und Sets zu, er kontrolliert und überarbeitet diese. Norbert
#   erstellt nach der Vorbereitung einen Snapshot fürs Archiv ZHdK. Die
#   Daten sind weiterhin im Medienarchiv sichtbar.  Im Medienarchiv hat er
#   die Rolle des "Experten".
#
# - Eine typische Abschlussarbeit ist ein Set mit ca. 5-20 verschiedenen
#   Medieneinträgen, die aus verschiedenen Medienformate
#   bestehen. Meistens enthalte diese ein PDF mit Projektbeschrieb, Fotos
#   zur Dokumentation, kleine Filme.
#
# - Norbert gruppiert die Abschlussarbeiten pro Jahrgang in Sets (Master
#   2012, Master 2011 ....).  Er bemüht sich, schrittweise auch
#   rückwirkend die Masterarbeiten der letzten beiden Jahre zu erfassen.
#
# - Norbert freut sich über die neue Hilfeseiten, in der der Prozess
#   erklärt ist. Da er nicht ständig im Medienarchiv arbeitet, braucht er
#   immer wieder eine kleine Auffrischung der Abläufe und eine Art
#   Checkliste, damit er keinen Schritt vergisst.

module Persona
  
  class Norbert
    
    @@name = "Norbert"
    @@lastname = "Neuerfassung"
    @@password = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_person
        create_user
        
        # NORBERT'S GROUPS
        join_expert_group
      end
    end

    def create_person
      @name = @@name
      @lastname = @@lastname  
      @person = FactoryGirl.create(:person, firstname: @name, lastname: @lastname)
    end

    def create_user
      @crypted_password = Digest::SHA1.hexdigest(@@password)
      @user = FactoryGirl.create(:user, :person => @person, :login => @name.downcase, :password => @crypted_password)
    end
    
    def join_expert_group
      @zhdk_group= Group.find_or_create_by_name("Expert")
      @zhdk_group.users << @user
    end
  end  
end