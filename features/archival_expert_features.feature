Feature: Exporting for archival experts and using the associated archival expert interface

  Fred prepares media entries for archival and passes copies of them on to Ginger
  Ginger checks whether everything is okay and then pulls XML-enriched copies of
  the archival stuff to her local machine in order to feed them into her archival
  system (e.g. TMS, The Museum System)


  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Fred Astaire" with username "fred" and password "tapping" exists
      And a user called "Ginger Rogers" with username "ginger" and password "dancing" exists
      And a group called "MIZ-Archiv" exists
      And a group called "Expert" exists
      And the user with username "fred" is member of the group "Expert"
      And the user with username "ginger" is member of the group "MIZ-Archiv"

  @javascript @work
  Scenario: Enter archival metadata for a media entry and then have an expert look at your copy
    Given I log in as "fred" with password "tapping"
      And I upload some picture titled "Tapping for the Archives"
      And I go to the home page
      And I click the media entry titled "Tapping for the Archives"
      And I follow "Metadaten für MIZ-Archiv editieren"
      And I wait for 6 seconds
      And I fill in the metadata form as follows:
      |label   |value             |options|
      |Autor/in|Things for archival|in-field entry box|
      |Untertitel|Things for archival||
      |Projekttitel|Things for archival||
      |Beschreibung|Things for archival||
      |Bildlegende|Things for archival||
      |Bemerkung|Things for archival||
      |Internet Links (URL)|Things for archival||
      |Standort/Aufführungsort|Things for archival||
      |Mitwirkende / weitere Personen|Things for archival||
      |Partner / beteiligte Institutionen|Things for archival||
      |Auftrag durch|Things for archival||
      |Porträtierte Person/en|Things for archival||
      |Porträtierte Institution|Things for archival||
      |Medienersteller/in|Things for archival|in-field entry box|
      |Weitere Personen Medienerstellung|Things for archival||
      |Dozierende/Projektleitung|Things for archival||
      |Angeboten durch|Things for archival||
      |Copyright|Things for archival||
      |Dimensionen|Things for archival||
      |Material/Format|Things for archival||
      |nur MIZ-Archiv\nArchivnummer|Things for archival||
      |nur MIZ-Archiv\nObjektbezeichnung|Things for archival||
      |Beschreibung durch|Things for archival|in-field entry box|
      And I press "Speichern"
     Then I should see "Die Änderungen wurden gespeichert."
     When I follow "MIZ-Archiv"
      And I wait for 3 seconds
     Then I should see "Things for archival"
     When I follow "Kopie für MIZ-Archiv erstellen"
     Then I should see "Ein Kopie dieses Medieneintrags wurde am"
     When I log in as "ginger" with password "dancing"
      And I click the arrow next to "Rogers, Ginger"
      And I follow "Kopien für MIZ-Archiv"
      And I click the media entry titled "Tapping for the Archives"
     Then I should see "Kopie für MIZ-Archiv editieren"



