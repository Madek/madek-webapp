Feature: Admin Meta Keys

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Creating a new meta key
    When I visit "/app_admin/meta_keys"
    Then I can see the "New Meta Key" link
    When I click on the link "New Meta Key"
    Then I am on the "/app_admin/meta_keys/new" page
    When I set the input with the name "meta_key[id]" to "test_meta_key"
    And I select "MetaDatumPeople" from "form-control"
    And I submit
    Then I can see a success message

  Scenario: Renaming the label of the key
    When I visit "/app_admin/meta_keys/project%20type/edit"
    Then I can see the input with the name "meta_key[id]" with value "project type"
    When I set the input with the name "meta_key[id]" to "project type edited"
    And I submit
    Then I can see a success message
    And I am on the "/app_admin/meta_keys/project%20type%20edited/edit" page
    And I can see the input with the name "meta_key[id]" with value "project type edited"
    When I visit "/app_admin/meta_keys/project%20type/edit"
    Then I cannot see the input with the name "meta_key[id]" with value "project type"

  Scenario: Listing meta keys with type info
    When I visit "/app_admin/meta_keys"
    Then I see the column with a meta datum object type

  Scenario: Listing meta keys with amount of resources
    When I visit "/app_admin/meta_keys"
    Then I see the column with a number of meta key resources

  Scenario: Listing meta keys with contexts
    When I visit "/app_admin/meta_keys"
    Then I see the column with contexts in which meta key is used

  Scenario: Filtering meta keys by label
    When I visit "/app_admin/meta_keys"
    Then I can see the input with the name "filter[label]" with no value
    When I set the input with the name "filter[label]" to "title"
    And I submit
    Then I can see only meta keys containing "title" term
    And I can see the input with the name "filter[label]" with value "title"

  Scenario: Filtering meta keys by their types
    When I visit "/app_admin/meta_keys"
    Then I see a select input with "filter[meta_datum_object_type]" name
    And There is no option selected in "filter[meta_datum_object_type]" select
    When I select "MetaDatumPeople" from the select node with the name "filter[meta_datum_object_type]"
    And I submit
    Then I can see only meta keys containing "MetaDatumPeople" term
    And There is "MetaDatumPeople" option selected in "filter[meta_datum_object_type]" select

  Scenario: Filtering meta keys by context
    When I visit "/app_admin/meta_keys"
    Then I see a select input with "filter[context]" name
    And There is no option selected in "filter[context]" select
    When I select "IO Interface" from the select node with the name "filter[context]"
    And I submit
    Then I can see only meta keys containing "IO Interface" term
    And There is "IO Interface" option selected in "filter[context]" select
