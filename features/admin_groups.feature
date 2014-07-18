Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  @jsbrowser
  Scenario: Deleting groups
    When I visit "/app_admin/groups"
    And I set the input with the name "filter[search_terms]" to "Expert"
    And I select "Group" from the select node with the name "type"
    And I submit
    Then I can see "Expert"
    When I remember the id of the first group-row
    And I click on the details link of the first row
    Then I can see the "Delete" link
    When I click on "Delete"
    And I confirm the browser dialog
    Then I can see a success message
    When I set the input with the name "filter[search_terms]" to "Expert"
    And I select "Group" from the select node with the name "type"
    And I submit
    And I cannot see "Expert"

  @jsbrowser
  Scenario: Adding and removing user to a group
    When I visit "/app_admin/groups"
    Then I see the user count
    When I click on the details link of the first row
    When I click on "Add user"
    And I see the submit button is disabled
    When I set the input with the name "[query]" to "nor"
    And I select first result from the autocomplete list
    Then The hidden field with name "[user_id]" should match "^\w+"
    And I see the submit button is enabled
    When I submit
    Then I can see a success message
    When I visit "/app_admin/groups"
    Then I see incremented user count
    When I click on the details link of the first row
    And I click on "Remove from group"
    When I visit "/app_admin/groups"
    Then I see decremented user count

  @jsbrowser
  Scenario: Adding user to a group by login
    When I visit "/app_admin/groups"
    And I click on the details link of the first row
    When I click on "Add user"
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
    When I select "Group" from the select node with the name "type"
    And I submit
    Then I see groups with "Group" type
    And I don't see groups with "MetaDepartment" type
    And There is "group" group type option selected
    When I select "MetaDepartment" from the select node with the name "type"
    And I submit
    Then I see groups with "MetaDepartment" type
    And I don't see groups with "Group" type
    And There is "meta_department" group type option selected

  Scenario: Create a new group
    When I visit "/app_admin/groups"
    And I click on "New group"
    And I set the input with the name "group[name]" to "AWESOME GROUP"
    And I submit
    Then I can see a success message
    And I can see "AWESOME GROUP"

  Scenario: Editing a group
    When I visit "/app_admin/groups"
    And I select "Group" from the select node with the name "type"
    And I submit
    And I click on the second Edit
    And I set the input with the name "group[name]" to "AWESOME GROUP"
    And I submit
    Then I can see a success message
    And I can see "AWESOME GROUP"

  Scenario: Editing a meta department
    When I visit "/app_admin/groups"
    And I select "MetaDepartment" from the select node with the name "type"
    And I submit
    And I click on the second Edit
    And I set the input with the name "meta_department[name]" to "AWESOME META DEPARTMENT"
    And I submit
    Then I can see a success message
    And I can see "AWESOME META DEPARTMENT"
