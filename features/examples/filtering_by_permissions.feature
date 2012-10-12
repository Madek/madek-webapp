Feature: Filtering by permissions

  As a MAdeK user
  I want to be able to filter resources by permissions after a search
  So that I can see all the resources that are owned by a specific person
  And so that I can see which resources I have specific permissions for (as 
  covered by the permissions presets)

  Background: Load the example data and personas
    Given personas are loaded
     And I am "Normin"
    When I go to the media resources
     And I see the filter panel

  @javascript
  Scenario: Filtering by owner
    Then I can filter so that I see only the media resources by each of the owners of any media resources shown

  @javascript
  Scenario: Filtering by group
    Then I can filter so that I see only the media resources that have view permissions relating to each of those groups

  @javascript
  Scenario: Filter by permissions
  	Then I can filter by "My content"
	   And I can filter by "Content assigned to me"
	   And I can filter by "Available to the public"
