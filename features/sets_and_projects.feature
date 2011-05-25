Feature: Do things to and with sets and projects

  Foo Bar

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Helmut Kohl" with username "helmi" and password "saumagen" exists
      And a user called "Mikhail Gorbachev" with username "gorbi" and password "glasnost" exists


  # This test makes sure that the titles we give are actually saved and also displayed/cached properly
  @javascript
  Scenario: Upload an image, then go to the detail page and add it to a set
    When I log in as "helmi" with password "saumagen"
     And I go to the home page
     And I follow "Hochladen"
     And I follow "Basic Uploader"
     And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
     And I press "Ausgewählte Medien hochladen und weiter…"
     And I wait for the CSS element "#submit_to_3"
     And I press "Einstellungen speichern und weiter…"
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |into the set after uploading|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set"
     And Sphinx is forced to reindex
     And I go to the media entries
     And I click the media entry titled "into the set after uploading"
     And I follow "Zu Set hinzufügen"
     And I press "Neues Set erstellen"
     And I wait for the CSS element "#text_media_set"
     And I fill in the set title with "After-Upload Set"
     And I press "Hinzufügen"
     And I press "Zu ausgewähltem Set hinzufügen"
     And Sphinx is forced to reindex
     And I go to the home page
    Then I should see "into the set after uploading"
    When I click the media entry titled "into the set after uploading"
    Then I should see "After-Upload Set"
     And I should not see "Ohne Titel"

 @javascript
  Scenario: Rename a set
    When I log in as "helmi" with password "saumagen"
     And I go to the home page
     And I follow "Hochladen"
     And I follow "Basic Uploader"
     And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
     And I press "Ausgewählte Medien hochladen und weiter…"
     And I wait for the CSS element "#submit_to_3"
     And I press "Einstellungen speichern und weiter…"
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |into the set after uploading|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set"
     And Sphinx is forced to reindex
     And I go to the media entries
     And I click the media entry titled "into the set after uploading"
     And I follow "Zu Set hinzufügen"
     And I press "Neues Set erstellen"
     And I wait for the CSS element "#text_media_set"
     And I fill in the set title with "After-Upload Set"
     And I press "Hinzufügen"
     And I press "Zu ausgewähltem Set hinzufügen"
     And Sphinx is forced to reindex
     And I go to the home page
     And I click the arrow next to "Kohl, Helmut"
     And I follow "Meine Sets"
     And I follow "After-Upload Set"
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel des Sets|Something new|
     And I press "Speichern" within ".save_buttons"
    Then I should see "Die Änderungen wurden gespeichert"
     And I should see "Something new"
     And I should not see "After-Upload Set"



  @javascript @work
  Scenario: Use a URL in a set description and expect it to turn into a link
    When I log in as "helmi" with password "saumagen"
     And I go to the home page
     And I follow "Hochladen"
     And I follow "Basic Uploader"
     And I attach the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory to "uploaded_data[]"
     And I press "Ausgewählte Medien hochladen und weiter…"
     And I wait for the CSS element "#submit_to_3"
     And I press "Einstellungen speichern und weiter…"
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |Link test|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set"
     And Sphinx is forced to reindex
     And I go to the media entries
     And I click the media entry titled "Link test"
     And I follow "Zu Set hinzufügen"
     And I press "Neues Set erstellen"
     And I wait for the CSS element "#text_media_set"
     And I fill in the set title with "Testing the link"
     And I press "Hinzufügen"
     And I press "Zu ausgewähltem Set hinzufügen"
     And Sphinx is forced to reindex
     And I go to the home page
    Then I should see "Link test"
    When I click the media entry titled "Link test"
     And I follow "Testing the link"
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Beschreibung|Here is a wonderful link http://www.zhdk.ch|
     And I press "Speichern"
    Then I should see "http://www.zhdk.ch"
    When I follow "http://www.zhdk.ch"
     
  