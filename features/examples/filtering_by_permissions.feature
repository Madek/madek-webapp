Feature: Filtering by permissions

  As a MAdeK user
  I want to be able to filter resources by permissions after a search
  So that I can see all the resources that are owned by a specific person
  And so that I can see which resources I have specific permissions for (as 
  covered by the permissions presets)

  Scenario: Filtering by owner
    When I see the filter panel
    Then I can filter so that I see only the media resources by each of the owners of any media resources shown

  Scenario: Filtering by group
    When I see the filter panel
    Then I can filter so that I see only the media resources that have view permissions relating to each of those groups

  Scenario: Filter by permissions
    When I see the filter panel
	Then I can filter by "My content"
	And I can filter by "Content assigned to me"
	And I can filter by "Available to the public"
