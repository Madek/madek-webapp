Feature: Admin Meta Contexts

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Adding meta key to a context
    When I visit "/app_admin/contexts"
    And I click on "Edit"
    And I click on "Add Meta Key Definition"
    Then I can see a form with id "new_meta_key_definition"
    When I select "version" from the select node with the name "meta_key_definition[meta_key_id]"
    And I select "Games" from the select node with the name "meta_key_definition[context_id]"
    And I set the input with the name "meta_key_definition[label]" to "LABEL"
    And I set the textarea with the name "meta_key_definition[hint]" to "HINT"
    And I set the textarea with the name "meta_key_definition[description]" to "DESCRIPTION"
    And I submit
    Then I can see a success message
    And I can see a row with values "version,LABEL,HINT,DESCRIPTION,No"

  Scenario: Deleting a context
    When I visit "/app_admin/contexts"
    And I click on "Delete"
    Then I can see a success message

  Scenario: Removing a meta key from a context
    When I visit "/app_admin/contexts"
    And I click on "Edit"
    And I click on "Remove"
    Then I can see a success message

  Scenario: Editing a context's description
    When I visit "/app_admin/contexts"
    And I click on "Edit"
    And I set the input with the name "context[description]" to "DESCRIPTION"
    And I submit
    Then I can see a success message
    And I can see "DESCRIPTION"

  Scenario: Displaying media sets on a separate page
    When I visit "/app_admin/contexts"
    And I click on the first "Media Sets" link in a table
    Then I am on a "/app_admin/contexts/.+/media_sets" page
    And I can see the list of related media sets
    And The list contains links to media sets

  Scenario: Displaying links to related meta keys
    When I visit "/app_admin/contexts"
    And I click on "Edit"
    Then I can see the links to related meta keys
    When I click on the first meta key link
    Then I am on the edit page related to the clicked meta key
