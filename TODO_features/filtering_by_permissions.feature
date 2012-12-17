Feature: Filtering by permissions

  As a MAdeK user
  I want to be able to filter resources by permissions after a search
  So that I can see all the resources a specific person is responsible for
  And so that I can see which resources I have specific permissions for (as 
  covered by the permissions presets)

  Background: Load the example data and personas
    Given personas are loaded
     And I am "Normin"
    When I go to the media resources
     And I see the filter panel

  @javascript
  Scenario: Filtering by responsibility
    Then I can filter so that I see only the media resources that have view permissions relating to each of those responsible users

  @javascript
  Scenario: Filtering by group
    Then I can filter so that I see only the media resources that have view permissions relating to each of those groups

  @javascript
  Scenario: Filtering by permission
    Then I can filter so that I see only the media resources that have view permissions relating to each of those permissions
     And I can filter by the "My content" scope
     And I can filter by the "Content assigned to me" scope
     And I can filter by the "Available to the public" scope
