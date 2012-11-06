Feature: Upload images and manage media entries based on images

  Foo Bar

  Background: Set up the world and some users
    Given I am "normin"
      
  @javascript
  Scenario: Upload one image file without any special metatada
     When I upload some picture titled "not a special picture"

  @javascript @slow
  Scenario: Upload an image file for another user to see
    When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                                |
     | Titel     | A beautiful piece of the Berlin Wall |
     | Rechte | Normalo, Normin                         |
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "A beautiful piece of the Berlin Wall"
     And I open the permission lightbox
     And I type "Land" into the "user" autocomplete field
     And I pick "Landschaft, Liselotte" from the autocomplete field
     And I give "view" permission to "Landschaft, Liselotte"
     And I click the arrow next to my name
     And I follow "Abmelden"
     And I am "liselotte"
     And I go to the home page
     Then I should see "A beautiful piece of the B..."

  @javascript @slow
  Scenario: Upload an image file for my group to see
    Given a group called "Mauerfäller" exists
      And the user with username "normin" is member of the group "Mauerfäller"
      And the user with username "liselotte" is member of the group "Mauerfäller"
      And I am "normin"
      And I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
      And I go to the upload edit
      And I fill in the metadata for entry number 1 as follows:
      | label     | value                             |
      | Titel     | A second piece of the Berlin Wall |
      | Rechte | Normalo, Normin                      |
      And I follow "weiter..."
      And I wait for the CSS element ".has-set-widget"
      And I follow "Import abschliessen"
      And I go to the home page
      And I click the media entry titled "A second piece of the Berlin Wall"
      And I open the permission lightbox
      And I type "Mauer" into the "group" autocomplete field
      And I pick "Mauerfäller" from the autocomplete field
      And I give "view" permission to "Mauerfäller"
      And I click the arrow next to my name
      And I follow "Abmelden"
      And I am "liselotte"
      And I go to the home page
      Then I should see "A second piece of the Berlin Wall"

  @javascript @slow
  Scenario: Add a single media entry to favorites from the media entry list
    When I upload some picture titled "mein lieblingsknödel"
     And I go to the media entries
     And I switch to the grid view
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsknödel"
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsknödel"

  @javascript @slow
  Scenario: Add a single media entry to favorites from the media detail page
    When I upload some picture titled "mein lieblingsdackel"
     And I go to the media entries
     And I click the media entry titled "mein lieblingsdackel"
     And I toggle the favorite star on this media entry
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsdackel"

  @javascript @slow
  Scenario: Add and remove a single media entry from favorites
    When I upload some picture titled "mein lieblingsbier"
     And I go to the media entries
     And I switch to the grid view
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsbier"
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsbier"
    When I go to the media entries
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsbier"
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should not see "mein lieblingsbier"

  @javascript @slow
  Scenario: Upload an image and delete it afterwards
    When I upload some picture titled "mein lieblingsflugzeug"
     And I go to the media entries
     And I switch to the grid view
     And all the entries controls become visible
     And I click the delete icon on the media entry titled "mein lieblingsflugzeug"
     And I go to the media entries
    Then I should not see "mein lieblingsflugzeug"

  @javascript
  Scenario: Upload an image that has MAdeK title and date information (specific date) its EXIF/IPTC metadata
    When I upload the file "features/data/images/date_should_be_2011-05-30.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Grumpy Cat"
    Then I should see "30.05.2011"

  @javascript @ts
  Scenario: Upload an image that has MAdeK metadata with a from/to date in its EXIF/IPTC metadata
    When I upload the file "features/data/images/date_should_be_from_to_may.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Frau-Sein"
    Then I should see "01.05.2011 - 31.05.2011"
     And I should see "Frau-Sein"
     And I should see "Buser, Monika"
     And I should see "Diplomarbeit, Porträt, Selbstporträt, Schweiz"

  @javascript @ts
  Scenario: Upload an image that has MAdeK metadata with a string instead of a date its EXIF/IPTC metadata
    When I upload the file "features/data/images/date_should_be_1990.jpg" relative to the Rails directory
     And I go to the upload edit
     And I follow "weiter..."
     And I wait for the CSS element ".has-set-widget"
     And I follow "Import abschliessen"
     And I go to the home page
     And I click the media entry titled "Frau-Sein"
    Then I should see "1990"
     And I should see "Frau-Sein"
     And I should see "Buser, Monika"
     And I should see "Diplomarbeit, Porträt, Selbstporträt, Schweiz"


