Feature: Explore Page

  Scenario: Elements of welcome page
    When I go to the home page
    And I click on the explore tab
    Then I am on the explore page
    Then I see a selection of the images of the teaser set
    And I see at most three elements of the catalog
    And I see sets of the featured sets
    And I can see the text "Häufige Schlagworte"


