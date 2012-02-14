Feature: Do things to and with sets

  In order to be able to work with sets and entries
  As a normal user
  I want to have functionalities for create and edit sets and manage entries

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Helmut Kohl" with username "helmi" and password "saumagen" exists
      And a user called "Mikhail Gorbachev" with username "gorbi" and password "glasnost" exists

  @javascript
  Scenario: Upload an image, then go to the detail page and add it to a set
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |into the set after uploading|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set…"
     And I go to the media entries
     And I wait for the CSS element "div.page div.item_box"
     And I click the media entry titled "into the set after uploading"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
    Then I see the set-box "After-Upload Set"
     And I should not see "Ohne Titel"

 @javascript 
  Scenario: Rename a set
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |into the set after uploading|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set…"
     And I go to the media entries
     And I click the media entry titled "into the set after uploading"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
     And I click the arrow next to "Kohl, Helmut"
     And I follow "Meine Sets"
     And I click the media entry titled "After-Upload Set"
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel des Sets|Something new|
     And I press "Speichern" within ".save_buttons"
    Then I should see "Die Änderungen wurden gespeichert"
     And I should see "Something new"
     And I should not see "After-Upload Set"

  @javascript
  Scenario: Use a URL in a set description and expect it to turn into a link
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     |label    |value                       |
     |Titel    |Link test|
     |Copyright|some other dude             |
     And I press "Metadaten speichern und weiter…"
     And I follow "Weiter ohne Hinzufügen zu einem Set…"
     And I go to the media entries
     And I click the media entry titled "Link test"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
    Then I should see "Link test"
    When I click the media entry titled "Link test"
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Beschreibung|Here is a wonderful link http://www.zhdk.ch|
     And I press "Speichern"
    Then I should see "http://www.zhdk.ch"
    When I follow "http://www.zhdk.ch"
     
