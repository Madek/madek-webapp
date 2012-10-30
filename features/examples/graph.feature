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

  @javascript
  Scenario: Browser Switcher
    Given I am "Normin"
      And I use Firefox
     When I open a complex graph
     Then I see the graph after its finished layouting/computing

  @javascript
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
      |open this media resource| # Diesen Inhalt öffnen
      |visualize all connected resources| # Alle verbundenen Inhalte visualisieren
      |visualize all my connected resources| # Alle meine verbundenen Inhalte visualisieren
      |visualize all descendants resources| # Alle untergeordneten Inhalte visualisieren
      |visualize all my descendants resources| # Alle meine untergeordneten Inhalte visualisieren


  @javascript
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
      |open this media resource| # Diesen Inhalt öffnen
      |visualize all connected resources| # Alle verbundenen Inhalte visualisieren
      |visualize all my connected resources| # Alle meine verbundenen Inhalte visualisieren
      |visualize all descendants resources| # Alle untergeordneten Inhalte visualisieren
      |visualize all my descendants resources| # Alle meine 

     