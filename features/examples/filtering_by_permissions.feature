Feature: Filtering by permissions

  As a MAdeK user
  I want to be able to filter resources by permissions after a search
  So that I can see all the resources that are owned by a specific person
  And so that I can see which resources I have specific permissions for (as 
  covered by the permissions presets)

  Scenario: Filtering by owner
    Given there are 20 media entries owned by 10 different owners
    When those entries appear in search results
    Then I can filter so that I see only the media entries by each of those owners

  Scenario: Filtering by group
    Given there are 20 media entries that belong to 3 different groups
    When those entries appear in search results
    Then I can filter so that I see only the media entries that have some permissions relating to each of those groups
