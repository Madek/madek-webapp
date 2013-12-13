Feature: Search

  As a MAdeK user
  I want to search resources
  So that I find resources

  Background: 
    Given I am signed-in as "Normin"

  Scenario: Suggested search terms
    When I go to the search page
    Then I see one suggested keyword that is randomly picked from the top 25 keywords of resources that I can see

   @jsbrowser
  Scenario: Searching for two words
    When I go to the search page
    And I set the input with the name "terms" to "Ausstellung ZHDK"
    And I submit
    Then The "resources_counter" has the same count as the "result_count"
    And I can see several resources


