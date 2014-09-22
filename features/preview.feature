Feature: Showing previews 

  @jsbrowser
  Scenario: Switching between, minature, grid and list
    Given I am signed-in as "Normin"
    And I visit "/media_resources"
    And I click on the link with the id "miniature-view"
    Then The link with the title "Miniatur-Ansicht" has the class "active"
    And The element with the id "ui-resources-list" has the class "miniature"
    And I click on the link with the id "grid-view"
    Then The link with the title "Raster-Ansicht" has the class "active"
    And The element with the id "ui-resources-list" has the class "grid"
    And I click on the link with the id "list-view"
    Then The link with the title "Listen-Ansicht" has the class "active"
    And The element with the id "ui-resources-list" has the class "list"
    And I click on the link with the id "tile-view"
    Then The link with the title "Kachel-Ansicht" has the class "active"
    And The element with the id "ui-resources-list" has the class "tiles"
    And The element with the id "ui-resources-list" has the class "vertical"