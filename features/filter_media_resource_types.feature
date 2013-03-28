Feature: Filter MediaResource Types 

  As a MAdeK user 
  I want to filter lists of resources by type
  So that can narrow down results

  @clean @jsbrowser
  Scenario: Filter a list of resources by type
    When I go to a list of resources
     And I open the filter
    Then I can filter by the type of media resources