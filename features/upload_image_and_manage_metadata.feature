Feature: Upload images and manage media entries based on images

  Foo Bar

  Background: Set up the world and some users
    Given I have set up the world a little
      And a user called "Helmut Kohl" with username "helmi" and password "saumagen" exists
      And a user called "Mikhail Gorbachev" with username "gorbi" and password "glasnost" exists

  @javascript 
  Scenario: Upload one image file without any special metatada
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "not a special picture"

  @javascript @broken
  Scenario: Upload an image and add it to a set
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                 |
     | Titel     | berlin wall for a set |
     | Rechte | some other dude       |
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I open the selection widget for this page
     And I create a new set named "Mauerstücke"
     And I submit the selection widget
     And I follow "Import abschliessen"
     And I go to the home page
     Then I should see "berlin wall for a set"
      And I should see "Mauerstücke"

  @javascript
  Scenario: Upload an image file for another user to see
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                                |
     | Titel     | A beautiful piece of the Berlin Wall |
     | Rechte | Kohl, Helmut                         |
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "A beautiful piece of the Berlin Wall"
     And I open the permission lightbox
     And I type "Gorba" into the "user" autocomplete field
     And I pick "Gorbachev, Mikhail" from the autocomplete field
     And I give "view" permission to "Gorbachev, Mikhail"
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Abmelden"
     And I log in as "gorbi" with password "glasnost"
     And I go to the home page
     Then I should see "A beautiful piece...f the Berlin Wall"

  @javascript
  Scenario: Upload an image file for my group to see
    Given a group called "Mauerfäller" exists
      And the user with username "helmi" is member of the group "Mauerfäller"
      And the user with username "gorbi" is member of the group "Mauerfäller"
      And I log in as "helmi" with password "saumagen"
      And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
      And I go to the upload edit
      And I fill in the metadata for entry number 1 as follows:
      | label     | value                             |
      | Titel     | A second piece of the Berlin Wall |
      | Rechte | Kohl, Helmut                      |
      And I follow "weiter..."
      And I wait for the CSS element ".has-set-widget"
      And I follow "Import abschliessen"
      And I go to the home page
      And I click the media entry titled "A second piece of the Berlin"
      And I open the permission lightbox
      And I type "Mauer" into the "group" autocomplete field
      And I pick "Mauerfäller" from the autocomplete field
      And I give "view" permission to "Mauerfäller"
      And I click on the arrow next to "Kohl, Helmut"
      And I follow "Abmelden"
      And I log in as "gorbi" with password "glasnost"
      And I go to the home page
      Then I should see "A second piece of the Berlin"

  @javascript
  Scenario: Make an uploaded file public
   Given a user called "Raissa Gorbacheva" with username "raissa" and password "novodevichy" exists
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "baustelle osten"
     And I go to the home page
     And I click the media entry titled "baustelle osten"
     And I open the permission lightbox
     And I give "view" permission to "Öffentlichkeit"
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should see "baustelle osten"

  @javascript
  Scenario: Upload a public file and then make it un-public again
   Given a user called "Raissa Gorbacheva" with username "raissa" and password "novodevichy" exists
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "geheimsache"
     And I go to the home page
     And I click the media entry titled "geheimsache"
     And I open the permission lightbox
     And I give "view" permission to "Öffentlichkeit"
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should see "geheimsache"
    When I log in as "helmi" with password "saumagen"
     And I click the media entry titled "geheimsache"
     And I open the permission lightbox
     And I remove "view" permission from "Öffentlichkeit"
     And I log in as "raissa" with password "novodevichy"
     And I go to the home page
    Then I should not see "geheimsache"

  @javascript
  Scenario: Give hi-resolution download permission on a file
   Given a user called "Hans Wurst" with username "hanswurst" and password "hansi" exists
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "hochaufgelöste geheimbünde"
     And I click the media entry titled "hochaufgelöste geheimbünde"
     And I open the permission lightbox
     And I type "Wurs" into the "user" autocomplete field
     And I pick "Wurst, Hans" from the autocomplete field
     And I give "view" permission to "Wurst, Hans"
     And I open the permission lightbox
     And I give "download" permission to "Wurst, Hans"
     And I log in as "hanswurst" with password "hansi"
     And I go to the home page
    Then I should see "hochaufgelöste geheimbünde"
    When I click the media entry titled "hochaufgelöste geheimbünde"
     And I follow "Exportieren"
    Then the box should have a hires download link

  @javascript 
  Scenario: Give and then revoke hi-resolution download permission on a file
   Given a user called "Hans Wurst" with username "hanswurst" and password "hansi" exists
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "hochaufgelöste geheimbünde"
     And I click the media entry titled "hochaufgelöste geheimbünde"
     And I open the permission lightbox
     And I type "Wurs" into the "user" autocomplete field
     And I pick "Wurst, Hans" from the autocomplete field
     And I give "view" permission to "Wurst, Hans"
     And I open the permission lightbox
     And I give "download" permission to "Wurst, Hans"
     And I log in as "hanswurst" with password "hansi"
     And I go to the home page
    Then I should see "hochaufgelöste geheimbünde"
    When I click the media entry titled "hochaufgelöste geheimbünde"
     And I follow "Exportieren"
    Then the box should have a hires download link
    When I log in as "helmi" with password "saumagen"
     And I click the media entry titled "hochaufgelöste geheimbünde"
     And I open the permission lightbox
     And I remove "download" permission from "Wurst, Hans"
     And I log in as "hanswurst" with password "hansi"
     And I go to the home page
    Then I should see "hochaufgelöste geheimbünde"
    When I click the media entry titled "hochaufgelöste geheimbünde"
     And I follow "Exportieren"
    Then the box should not have a hires download link


  @javascript
  Scenario: Add a single media entry to favorites from the media entry list
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "mein lieblingsknödel"
     And I go to the media entries
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsknödel"
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsknödel"

  @javascript
  Scenario: Add a single media entry to favorites from the media detail page
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "mein lieblingsdackel"
     And I go to the media entries
     And I click the media entry titled "mein lieblingsdackel"
     And I toggle the favorite star on this media entry
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsdackel"

  @javascript 
  Scenario: Add and remove a single media entry from favorites
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "mein lieblingsbier"
     And I go to the media entries
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsbier"
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsbier"
    When I go to the media entries
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsbier"
     And I click on the arrow next to "Kohl, Helmut"
     And I follow "Meine Favoriten"
    Then I should not see "mein lieblingsbier"

  @javascript 
  Scenario: Upload an image and delete it afterwards
    When I log in as "helmi" with password "saumagen"
     And I upload some picture titled "mein lieblingsflugzeug"
     And I go to the media entries
     And all the entries controls become visible
     And I click the delete icon on the media entry titled "mein lieblingsflugzeug"
     And I go to the media entries
    Then I should not see "mein lieblingsflugzeug"

  @javascript
  Scenario: Upload an image that has MAdeK title and date information (specific date) its EXIF/IPTC metadata
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/date_should_be_2011-05-30.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Grumpy Cat"
    Then I should see "30.05.2011"

  @javascript @ts
  Scenario: Upload an image that has MAdeK metadata with a from/to date in its EXIF/IPTC metadata
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/date_should_be_from_to_may.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Frau-Sein"
    # The below stuff would better be done with a Cucumber table, so you can do e.g.:
    # |field|value|
    # |Datierung|1990|
    # So that we can specify the "should be..." part of a media entry like we specify the
    # metadata editor part.
    Then I should see "01.05.2011 - 31.05.2011"
     And I should see "Frau-Sein"
     And I should see "Buser, Monika"
     And I should see "Diplomarbeit, Porträt, Selbstporträt, Schweiz"

  @javascript @ts
  Scenario: Upload an image that has MAdeK metadata with a string instead of a date its EXIF/IPTC metadata
    When I log in as "helmi" with password "saumagen"
     And I upload the file "features/data/images/date_should_be_1990.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Frau-Sein"
    # The below stuff would better be done with a Cucumber table, so you can do e.g.:
    # |field|value|
    # |Datierung|1990|
    # So that we can specify the "should be..." part of a media entry like we specify the
    # metadata editor part.
    Then I should see "1990"
     And I should see "Frau-Sein"
     And I should see "Buser, Monika"
     And I should see "Diplomarbeit, Porträt, Selbstporträt, Schweiz"


