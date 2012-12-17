Feature: Welcome Page

  Scenario: Elements of welcome page
    When I go to the home page
    Then I see a selection of the images of the teaser set
    And I see at most three elements of the catalog
    And I see sets of the featured sets
    And I see new content
    And I see a ZHdK-Login
    And I see a database login
    And I see an explore tab
    And I see an help tab
    When I go to the home page
    And I click on show me more of the catalog
    Then I am on the catalog page
    When I go to the home page
    And I click on the explore tab
    Then I am on the explore page
    When I go to the home page
    And I click on show me more of the featured sets
    Then I am on the featured sets set page
    When I go to the home page

