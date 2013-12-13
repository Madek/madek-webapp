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
    Then The hidden field with name "[user_id]" should match "^\w+$"
    And I see the submit button is enabled
    When I submit
    Then I can see a success message

  @jsbrowser
  Scenario: Adding user to a group by login
    When I visit "/app_admin/groups/2/form_add_user"
    And I see the submit button is disabled
    When I set the input with the name "[query]" to "[norbert]"
    Then The hidden field with name "[user_id]" should match ""
    And I see the submit button is enabled
    When I submit
    Then I can see a success message

  Scenario: Listing all groups with their types
    When I visit "/app_admin/groups"
    Then I see the column with a group type
    And I see the "Group" type in the group list
    And I see the "MetaDepartment" type in the group list

  Scenario: Filtering groups by their types
    When I visit "/app_admin/groups"
    Then I see a select input with "type" name
    And There is "all" group type option selected
    When I select "Group" from "form-control"
    And I submit
    Then I see groups with "Group" type
    And I don't see groups with "MetaDepartment" type
    And There is "group" group type option selected
    When I select "MetaDepartment" from "form-control"
    And I submit
    Then I see groups with "MetaDepartment" type
    And I don't see groups with "Group" type
    And There is "meta_department" group type option selected
