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
     And I attach the file "spec/data/images/berlin_wall_01.jpg" to "uploaded_data[]"
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
     And I go to the home page
     Then I should see "berlin wall for a set"

  @javascript
  Scenario: Upload an image file for another user to see

  @javascript
  Scenario: Upload an image file for my group to see

  @javascript
  Scenario: Make an uploaded file public

  @javascript
  Scenario: Upload a public file and then make it un-public again

  @javascript
  Scenario: Give hi-resolution download permission on a file

  @javascript
  Scenario: Give and then revoke hi-resolution download permission on a file