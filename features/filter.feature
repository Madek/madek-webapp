Feature: Filter

  As a MAdeK user 
  I want to filter lists of resources
  So that can narrow down results

  @clean
  Scenario: Filter by "any" value
    When I see a list of resources
     And I open the filter
     And I select the "any" value checkbox for a specific key
    Then the list shows only resources that have any value for that key
    
