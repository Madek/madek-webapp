Feature: Dashboard

  Background: 
    Given I am signed-in as "Normin"


  Scenario: My resources
    Given I am on the dashboard
    Then I see a block of resources showing my content
    And There is a link to my resources
    When I follow the link to my resources
    Then I am on the my resources page


  Scenario: Showing last imports
    Given I am on the dashboard
    Then I see a block of resources showing my last imports

  Scenario: Favorites
    Given I am on the dashboard
    Then I see a block of resources showing my favorites
    And There is a link to my favorites
    When I follow the link to my favorites page
    Then I am on the my favorites

  Scenario: Keywords
    Given I am on the dashboard
    Then I see a block of my keywords
    And There is a link to my keywords
    When I follow the link to my keywords
    Then I am on the my keywords page

  Scenario: Assigned to me
    Given I am on the dashboard
    Then I see a block of resources showing content assigned to me
    And There is a link to content assigned to me
    When I follow the link to content assigned to me
    Then I am on the content assigned to me page

  Scenario: My groups
    Given I am on the dashboard
    Then I see a list of my groups
    And There is a link to my groups
    When I follow the link to my groups
    Then I am on the my groups page

