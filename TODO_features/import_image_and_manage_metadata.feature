Feature: import images and manage media entries based on images

  Foo Bar

  Background: Set up the world and some users
    Given I am "normin"
      
  @poltergeist
  Scenario: import one image file without any special metatada
     When I import some picture titled "not a special picture"


  @poltergeist 
  Scenario: Add a single media entry to favorites from the media entry list
    When I import some picture titled "mein lieblingsknödel"
     And I go to the media entries
     And I switch to the grid view
     And all the entries controls become visible
     And I toggle the favorite star on the media entry titled "mein lieblingsknödel"
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsknödel"

  @poltergeist 
  Scenario: Add a single media entry to favorites from the media detail page
    When I import some picture titled "mein lieblingsdackel"
     And I go to the media entries
     And I click the media entry titled "mein lieblingsdackel"
     And I toggle the favorite star on this media entry
     And I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I should see "mein lieblingsdackel"

  @poltergeist 
  Scenario: Add and remove a single media entry from favorites
    When I import some picture titled "mein lieblingsbier"
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

  @poltergeist 
  Scenario: import an image and delete it afterwards
    When I import some picture titled "mein lieblingsflugzeug"
     And I go to the media entries
     And I switch to the grid view
     And all the entries controls become visible
     And I click the delete icon on the media entry titled "mein lieblingsflugzeug"
     And I go to the media entries
    Then I should not see "mein lieblingsflugzeug"

