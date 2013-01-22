Feature: Filter set

  As a MAdeK user
  I want to organize automatically generated relations of resources
  So that I can track resources related to specific topics

  Scenario: Create filter set
    When I see the search results page
     And I use the filter
     And I create a filter set
     And I provide a name
    Then the filter set is created

  Scenario: Edit filter set
    When I open a filter set
     And I edit the filter set settings
     And I change the settings for that filter set
     And I save these changes
    Then the filter set settings are updated

  Scenario: See filter set settings
   When I open a filter set
   Then I can see the settings of that filter set