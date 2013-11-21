Feature: Showing previews 

  @jsbrowser
  Scenario: Switching between, minature, grid and list
    Given I am signed-in as "Normin"
    And I visit "/media_resources"
    And I click on the link with the id "miniature-view"
    Then The link with the title "Miniatur-Ansicht" hash the class "active"
    And The element with the id "ui-resources-list" hash the class "miniature"
    And I click on the link with the id "grid-view"
    Then The link with the title "Raster-Ansicht" hash the class "active"
    And The element with the id "ui-resources-list" hash the class "grid"
    And I click on the link with the id "list-view"
    Then The link with the title "Listen-Ansicht" hash the class "active"
    And The element with the id "ui-resources-list" hash the class "list"
