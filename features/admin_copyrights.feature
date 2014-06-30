Feature: Managing Copyrigts
  
  As a MAdeK admin

  Background:
    Given I am signed-in as "Adam"

  Scenario: Editing a copyright
    When I visit "/app_admin/copyrights"
    And I click on "Details"
    And I click on "Edit"
    And I set the input with the name "copyright[label]" to "AWESOME COPYRIGHT"
    And I submit
    Then I can see a success message
    And I can see "AWESOME COPYRIGHT"

  Scenario: Creating a new copyright
    When I visit "/app_admin/copyrights"
    And I click on "New copyright"
    And I set the input with the name "copyright[label]" to "NEW COPYRIGHT"
    And I submit
    Then I can see a success message
    And I can see "NEW COPYRIGHT"

  Scenario: Editing parent id not possible for copyright with children
    When I visit "/app_admin/copyrights"
    And I click on the parent details
    And I click on "Edit"
    Then I cannot see "Parent id"
