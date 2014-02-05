Feature: Statistics page

  As a MAdek admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Visiting the page with statistics
    When I visit "/app_admin"
    Then I see the "Info + Statistics" menu item
    When I click on "Info + Statistics"
    Then I can see the text "Info and Statistics"

  Scenario: Listing amounts of all categories
    When I visit "/app_admin"
    And I click on "Info + Statistics"
    Then I can see the amounts of all admin panel categories
