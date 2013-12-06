Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  @jsbrowser
  Scenario: Deleting groups
    When I visit "/app_admin/groups"
    Then I can see "DDE_FDE_BDE.alle"
    When I visit "/app_admin/groups/651"
    Then I can see the "Delete" link
    When I click on "Delete"
    And I confirm the browser dialog
    Then I can see a success message
    And I cannot see "DDE_FDE_BDE.alle"

  @jsbrowser
  Scenario: Adding user to a group 
    When I visit "/app_admin/groups"
    And I click on "Details"
    Then I am on the group page with id "2"
    When I click on "Add user"
    Then I am on the page where I can add a user to the group with id "2"
    And I see the submit button is disabled
    When I set the input with the name "[query]" to "nor"
    And I select first result from the autocomplete list
    Then The hidden field with name "[user_id]" should have a value
    And I see the submit button is enabled
    When I submit
    Then I can see a success message
