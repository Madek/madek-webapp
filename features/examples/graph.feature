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