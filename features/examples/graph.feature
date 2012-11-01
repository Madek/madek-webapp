Feature: Visualization / Graph

  As a MAdeK user
  I want a tool that is visualizing the realtionships between media resources
  So that I understand structures better

  Background: Load the example data and personas
    Given personas are loaded

  @javascript
  Scenario: Calculate graph on the media set view
    Given I am "Normin"
    When I open a set that has children and parents
     And I use the "show graph" context action
    Then I can see the relations for that resource

  @javascript
  Scenario: Calculate graph on the media entry view
    Given I am "Normin"
    When I open a media entry that is child of a set that I can see
     And I use the "show graph" context action
    Then I can see the relations for that resource

  @javascript
  Scenario: Calculate graph on a filtered list
    Given I am "Normin"
    Given I see a filtered list of resources where at least one element has arcs
     And I use the "show graph" context action
    Then I can see the relations for that resources

  @poltergeist
  Scenario: Browser Switcher
    Given I am "Normin"
      And I use Firefox
     When I open a complex graph
     Then I see the graph after its finished layouting/computing

  @poltergeist
  Scenario: Popup for a set
    Given I am "Normin"
     When I a see a graph
      And I inspect a media set node more closely
     Then I see a popup
      And I see the title of that resource
      And I see the permission icon for that resource
      And I see the favorite status for that resource
      And I see the number of children devided by media entry and media set
      And I have the following option:
      |Option|
      |open this media resource|
      |visualize all connected resources|
      |visualize all my connected resources|
      |visualize all descendants resources|
      |visualize all my descendants resources|


  @poltergeist
  Scenario: Popup for a media entry
    Given I am "Normin"
     When I a see a graph
      And I inspect a media entry node more closely
      Then I see a popup
      And I see the title of that resource
      And I see the permission icon for that resource
      And I see the favorite status for that resource
      And I dont see any number of children and parents
      And I have the following option:
      |Option|
      |open this media resource| 
      |visualize all connected resources| 
      |visualize all my connected resources| 

  @poltergeist
  Scenario: Title
    Given I am "Normin"
     When I a see a graph
     Then I see a title
     When I visualize the filter "Meine Sets"
     Then I see the title "Meine Sets"
     When I visualize the filter "Meine Inhalte"
     Then I see the title "Meine Inhalte"
     When I visualize the filter "Mir anvertraute Inhalte"
     Then I see the title "Meine anvertraute Inhalte"
     When I visualize the filter "Meine Favoriten"
     Then I see the title "Meine Favoriten"
     When I visualize the filter Suchergebnisse für "Land"
     Then I see the title "Suchergebnisse für Land"

  @poltergeist
  Scenario: Title
    Given I am "Normin"
     When I a see a graph
     And I get rid of the anoying browser warning
     When I visualize the descendants of a Set
     Then I see the originating set beeing highlighted
     And I see the title of the set as graph-title
     When I visualize the component of a Entry
     Then I see the originating entry beeing highlighted
     And I see the title of the entry as graph-title

  @wip @poltergeist
  Scenario: Default labels
    Given I am "Normin"
     And  There are no persisted visualizations
     When I a see the graph of the resource "my_media_resources"
     And I get rid of the anoying browser warning
     Then the label option "sets_having_descendants" is selected 
     Then I see by default exactly the labels of the sets that have children in the current visualization

  @wip @poltergeist
  Scenario: Selecting and saving the option all labels
    Given I am "Normin"
     And  There are no persisted visualizations
     When I a see the graph of the resource "my_media_resources"
     And I get rid of the anoying browser warning
     When I select "all" of the label select options 
     And  I wait for persisting the options
     And  I revisit the current_path
     Then the label option "sets_having_descendants" is selected 
     And I see that all labels are show 

  @wip @poltergeist
  Scenario: Selecting and saving the option all labels
    Given I am "Normin"
     And  There are no persisted visualizations
     When I a see the graph of the resource "my_media_resources"
     And I get rid of the anoying browser warning
     When I select "all" of the label select options 
     And  I wait for persisting the options
     And  I revisit the current_path
     Then the label option "sets_having_descendants" is selected 
     And I see that all labels are show 

