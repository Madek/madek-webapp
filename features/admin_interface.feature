Feature: Admin Interface

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Going back to media archive
    When I visit "/app_admin"
    Then I see the return link in the navbar
    When I click on the link "return to user-interface"
    Then I am redirected to the media archive
