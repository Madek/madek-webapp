  Feature: Admin interface

  As a MAdeK admin

  Background:
    Given I am signed-in as "Adam"

  Scenario: Updating Usage Terms
    When I visit "/app_admin/usage_terms"
    And I click on "Edit"
    When I set the input with the name "usage_term[title]" to "New title"
    And I submit
    Then I can see a success message
    And I see the Akzeptieren button

  @jsbrowser
  Scenario: Resetting usage terms acceptance of a user
    When I visit "/app_admin/admin_users"
    And I click on "Reset usage terms"
    Then I see the Akzeptieren button
