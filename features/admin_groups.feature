Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  @firefox
  Scenario: Deleting groups
    When I visit "/app_admin/groups"
    Then I can see "DDE_FDE_BDE.alle"
    When I visit "/app_admin/groups/651"
    Then I can see the "Delete" link
    When I click on "Delete"
    And I confirm the browser dialog
    Then I can see a success message
    And I cannot see "DDE_FDE_BDE.alle"
