Feature: Upload images and manage media entries based on images

  Foo

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Helmut Kohl" with username "helmi" and password "schweinsmagen" exists
      And a user called "Mikhail Gorbachev" with username "gorbi" and password "glasnost" exists


  @javascript
  Scenario: Upload one image file without any special metatada
    When I log in as "helmi" with password "schweinsmagen"
     And I upload some picture titled "not a special picture"

  @javascript
  Scenario: Upload an image and add it to a set
    When I log in as "helmi" with password "schweinsmagen"
     And I go to the home page
     And I follow "Hochladen"
     And I follow "Basic Uploader"
     And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
     And I press "Ausgewählte Medien hochladen »"
     And I wait for the CSS element "#submit_to_3"
     And I press "Einstellungen speichern und weiter »"
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                |
     |Titel    |berlin wall for a set|
     |Copyright|some other dude      |
     And I press "Metadaten speichern und weiter »"
     And I press "Neu"
     And I wait for the CSS element "#text_media_set"
     And I fill in the set title with "Mauerstücke"
     And I press "Hinzufügen"
     And I press "Gruppierungseinstellungen speichern"
     And Sphinx is forced to reindex
     And I go to the home page
     Then I should see "berlin wall for a set"

  @javascript
  Scenario: Upload an image file for another user to see
    When I log in as "helmi" with password "schweinsmagen"
     And I follow "Hochladen"
     And I follow "Basic Uploader"
     And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
     And I press "Ausgewählte Medien hochladen »"
     And I wait for the CSS element "#submit_to_3"
     And I press "Einstellungen speichern und weiter »"
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                               |
     |Titel    |A beautiful piece of the Berlin Wall|
     |Copyright|Kohl, Helmut                        |
     And I press "Metadaten speichern und weiter »"
     And I follow "Weiter ohne Gruppierung"
     And Sphinx is forced to reindex
     And I go to the home page
     And I click the media entry titled "A beautiful piece of the B..."
     And I follow "Zugriffsberechtigung"
     And I type "Gorba" into the "user" autocomplete field
     And I pick "Gorbachev, Mikhail" from the autocomplete field
     And I give "view" permission to "Gorbachev, Mikhail"
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Abmelden"
     And I log in as "gorbi" with password "glasnost"
     And I go to the home page
     Then I should see "A beautiful piece of the B..."


  @javascript
  Scenario: Upload an image file for my group to see
    Given a group called "Mauerfäller" exists
      And the user with username "helmi" is member of the group "Mauerfäller"
      And the user with username "gorbi" is member of the group "Mauerfäller"
      And I log in as "helmi" with password "schweinsmagen"
      And Sphinx is forced to reindex
      And I go to the home page
      And I follow "Hochladen"
      And I follow "Basic Uploader"
      And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
      And I press "Ausgewählte Medien hochladen »"
      And I wait for the CSS element "#submit_to_3"
      And I press "Einstellungen speichern und weiter »"
      And I fill in the metadata for entry number 1 as follows:
      |label    |value                            |
      |Titel    |A second piece of the Berlin Wall|
      |Copyright|Kohl, Helmut                     |
      And I press "Metadaten speichern und weiter »"
      And I follow "Weiter ohne Gruppierung"
      And Sphinx is forced to reindex
      And I go to the home page
      And I click the media entry titled "A second piece of the Berl..."
      And I follow "Zugriffsberechtigung"
      And I type "Mauer" into the "group" autocomplete field
      And I pick "Mauerfäller" from the autocomplete field
      And I give "view" permission to "Mauerfäller"
      And I click on the arrow next to "Kohl, Helmut"
      And I follow "Abmelden"
      And I log in as "gorbi" with password "glasnost"
      And I go to the home page
      Then I should see "A second piece of the Berl..." 

  @javascript
  Scenario: Make an uploaded file public
   Given a user called "Raissa Gorbacheva" with username "raissa" and password "novodevichy" exists
    When I log in as "helmi" with password "schweinsmagen"
     And I upload some picture titled "baustelle osten"
     And I go to the home page
     And I click the media entry titled "baustelle osten"
     And I follow "Zugriffsberechtigung"
     And I give "view" permission to "everybody"
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should see "baustelle osten"
     

  @javascript 
  Scenario: Upload a public file and then make it un-public again
   Given a user called "Raissa Gorbacheva" with username "raissa" and password "novodevichy" exists
    When I log in as "helmi" with password "schweinsmagen"
     And I upload some picture titled "geheimsache"
     And I go to the home page
     And I click the media entry titled "geheimsache"
     And I follow "Zugriffsberechtigung"
     And I give "view" permission to "everybody"
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should see "geheimsache"
    When I log in as "helmi" with password "schweinsmagen"
     And I click the media entry titled "geheimsache"
     And I follow "Zugriffsberechtigung"
     And I remove "view" permission from "everybody"
     And Sphinx is forced to reindex
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should not see "geheimsache"


  @javascript
  Scenario: Give hi-resolution download permission on a file
   Given a user called "Hans Wurst" with username "hanswurst" and password "hansi" exists
    When I log in as "helmi" with password "schweinsmagen"
     And I upload some picture titled "hochaufgelöste geheimbünde"
     And I click the media entry titled "hochaufgelöste geheimbünde"
     And I follow "Zugriffsberechtigung"
     And I type "Wurs" into the "user" autocomplete field
     And I pick "Wurst, Hans" from the autocomplete field
     And I give "view" permission to "Wurst, Hans"
     And I give "download_hires" permission to "Wurst, Hans"
     And I log in as "hanswurst" with password "hansi"
     And I go to the home page
    Then I should see "hochaufgelöste geheimbünde"
    When I click the media entry titled "hochaufgelöste geheimbünde"
     And I follow "Exportieren"
    Then the box should have a hires download link

  @javascript
  Scenario: Give and then revoke hi-resolution download permission on a file