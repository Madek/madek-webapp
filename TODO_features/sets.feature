Feature: Different Actions of Sets
Add to favorite, Add to set during import, Rename a set, URL in free text description, set popup, resource hover, assigning contexts to sets, viewing a context, top-level sets

  Background: Set up the world with a user and logging in
    Given a user called "Max" with username "max" and password "password" exists
      And I am "max"

  @poltergeist
  Scenario: Add a set to my favorites
   Given I see some sets
    When I add them to my favorites
    Then they are in my favorites
    And I can open them and see that are set as favorite

  @javascript
  Scenario: Upload an image, then go to the detail page and add it to a set
    When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                        |
     | Titel     | into the set after uploading |
     | Rechte | some other dude              |
     And I follow "weiter..."
     And I follow "Import abschliessen"
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
     When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                        |
     | Titel     | into the set after uploading |
     | Rechte | some other dude              |
     And I follow "weiter..."
     And I follow "Import abschliessen"
     And I go to the media entries
     And I click the media entry titled "into the set after uploading"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
     And I click the arrow next to my name
     And I follow "Meine Sets"
     And I click the media entry titled "After-Upload Set"
     And I hover the context actions menu
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|Something new|
     And I press "Speichern" within ".save_buttons"
    Then I should see "Die Änderungen wurden gespeichert"
     And I should see "Something new"
     And I should not see "After-Upload Set"

  @javascript
  Scenario: Use a URL in a set description and expect it to turn into a link
     When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value           |
     | Titel     | Link test       |
     | Rechte | some other dude |
     And I follow "weiter..."
     And I follow "Import abschliessen"
     And I go to the media entries
     And I click the media entry titled "Link test"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
    Then I should see "Link test"
    When I click the media entry titled "Link test"
     And I hover the context actions menu
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     | label        | value                                       |
     | Beschreibung | Here is a wonderful link http://www.zhdk.ch |
     And I press "Speichern"
     And I expand the "Metadaten" context group
    Then I should see "http://www.zhdk.ch"
    When I follow "http://www.zhdk.ch"

  # https://www.pivotaltracker.com/story/show/23825307
  @poltergeist
  Scenario: Preview of content and relationships of a set in the grid view called set popup
    Given I am "Normin"
     When I view a grid of sets
      And I examine a visible set that has children and parents more closely
     Then I see relationships for this set
      And I see how many media entries that are viewable for me in this set
      And I see how many sets that are viewable for me in this set
      And I see previews of the resources that are children of this set
      When I hover those previews of children I see the title of those resources 
      And I see how many sets that are viewable for me are parents of this set
      And I see previews of the resources that are parent of this set
      When I hover those previews of parents I see the title of those resources
      
  @poltergeist
  Scenario: MediaEntry popup on a media set page called resource hover
    Given I am "Normin"
      And I open a set which has child media entries
      And I switch the list of the childs to the miniature view
      And I examine one of the child media entry more closely
     Then I see more information about that media entry popping up

  # https://www.pivotaltracker.com/story/show/22394303
  @poltergeist
  Scenario: Choosing which contexts are valid for a set, assigning contexts to sets
   Given I am "Adam"
     And a context called "Landschaftsvisualisierung" exists
     And a context called "Zett" exists
     And a context called "Games" exists
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" that has the context "Games"
     And the set called "Zett über Landschaften" is child of "Landschaften" and "Zett"
     And I can edit the set "Zett über Landschaften"
    When I view the set "Zett über Landschaften"
    Then I see the available contexts "Landschaftsvisualisierung" and "Zett"
     And I see some text explaining the consequences of assigning contexts to a set
    When I assign the context "Zett" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Zett"
    When I assign the context "Landschaftsvisualisierung" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Landschaftsvisualisierung"
     And the set still has the context called "Games"

  # https://www.pivotaltracker.com/story/show/22464659
  @poltergeist
  Scenario: Viewing which contexts a set could have
   Given I am "Adam"
     And a context called "Landschaftsvisualisierung" exists
     And a context called "Zett" exists
     And a context called "Games" exists
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" that has the context "Games"
     And the set called "Zett über Landschaften" is child of "Landschaften" and "Zett"
    When I view the set "Zett über Landschaften"
    Then I can choose to see more details about the context "Zett"
     And I can choose to see more details about the context "Landschaftsvisualisierung"
     And I can choose to see more details about the context "Games"


  # https://www.pivotaltracker.com/story/show/22576523
  # https://www.pivotaltracker.com/story/show/23800945
  Scenario: Viewing a context
    Given a context
     When I look at a page describing this context
     Then the page's look is consistent with the rest of the application
      And I see all the keys that can be used in this context
      And I see all the values those keys can have
      And I see an abstract of the most assigned values from media entries using this context

  # https://www.pivotaltracker.com/story/show/23825857
  Scenario: Switch between all sets and main sets on the page 'my sets'
    Given a few sets
     When I view a list of my sets
     Then I see a list of all my sets
      And I can switch to a list of my top-level sets
     When I view a list of all my sets
     Then I see all my sets

  # https://www.pivotaltracker.com/story/show/23825857
  # Use @persona-dump if you want to load the persona dump and use truncation even in a non-javsacript step
  @glossary
  Scenario: Top-level set
    Given a few sets
     When a set has no parents
     Then it is a top-level set
