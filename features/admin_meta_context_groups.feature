Feature: Admin Meta Context Groups

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Removing a meta context
    When I visit "/app_admin/meta_context_groups"
    And I click on "Edit"
    Then I can see a list of "4" meta contexts
    When I check the first remove checkbox
    And I submit
    Then I can see a success message
    When I click on "Edit"
    Then I can see a list of "3" meta contexts
