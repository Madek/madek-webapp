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

  @clean @jsbrowser 
  Scenario: Filter by free-text search-term
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I set the input with the name "search" to "Landschaft" and submit
     And I wait for the number of resources to change
     Then the number or resources is lower then before

  @clean @jsbrowser
  Scenario: Filter by file
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Datei"
     And I click on the link "Medientyp"
     And I remember the count for the filter "image"
     And I click on the link "image"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser 
  Scenario: Filter by permissions
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Berechtigung"
     And I click on the link "Verantwortliche Person"
     And I remember the count for the filter "Knacknuss, Karen"
     And I click on the link "Knacknuss, Karen"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser 
  Scenario: Filter by work
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Werk"
     And I click on the link "Schlagworte zu Inhalt und Motiv"
     And I remember the count for the filter "Fotografie"
     And I click on the link "Fotografie"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser 
  Scenario: Filter by "Landschaftsvisualisierung"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Landschaftsvisualisierung"
     And I take a screenshot
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser 
  Scenario: Filter by Medium
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Medium"
     And I click on the link "Material/Format"
     And I remember the count for the filter "8-Kanal Audio"
     And I click on the link "8-Kanal Audio"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser 
  Scenario: Filter by "Säulenordnungen"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Säulenordnungen"
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser
  Scenario: Filter by "ZHdK"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "ZHdK"
     And I click on the link "ZHdK-Projekttyp"
     And I remember the count for the filter "Abschlussarbeit"
     And I click on the link "Abschlussarbeit"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

  @clean @jsbrowser
  Scenario: Filter by "Lehrmittel Fotografie"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Lehrmittel Fotografie"
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered count

