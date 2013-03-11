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
    

  @clean @jsbrowser
  Scenario: Existence of the filter-panel and searching for an empty term
    Given I am signed-in as "Liselotte"
    And I click on the link "Suchen"
    Then I am on the "/search" page
    When I click the submit input
    Then I can see the filter panel
    And The filter panel contains a search input
    And The filter panel contains a top-filter-list
    And The filter panel contains the top filter "Datei"
    And The filter panel contains the top filter "Berechtigung"
    And The filter panel contains the top filter "Werk"
    And The filter panel contains the top filter "Landschaftsvisualisierung"
    And The filter panel contains the top filter "Medium"
    And The filter panel contains the top filter "Säulenordnung"
    And The filter panel contains the top filter "ZHdK"
    And The filter panel contains the top filter "Lehrmittel Fotografie"








