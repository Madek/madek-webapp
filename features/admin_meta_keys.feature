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
    When I select "Core" from the select node with the name "filter[context]"
    And I submit
    Then I can see only meta keys containing "Core" term
    And There is "Core" option selected in "filter[context]" select

  Scenario: Filtering meta keys by used / not used status
    When I visit "/app_admin/meta_keys"
    Then I see a select input with "filter[is_used]" name
    And There is no option selected in "filter[is_used]" select
    When I select "Not used" from the select node with the name "filter[is_used]"
    And I submit
    Then I can see only meta keys containing "Not used" term

  Scenario: Deleting not used meta key
    When I visit "/app_admin/meta_keys?is_used=false"
    Then I can see delete links in a table
    And I click on "Delete"
    Then I can see a success message
    And There is one less delete link
 
  @firefox
  Scenario: Applying alphabetical order to meta terms
    When I visit "/app_admin/meta_keys?filter[meta_datum_object_type]=MetaDatumMetaTerms"
    And I click on "Edit"
    Then I can see the "Apply Alphabetical Order" link
    When I click on "Apply Alphabetical Order"
    Then There is the input with name "meta_key[meta_terms_alphabetical_order]" set to "1"
    And The meta terms are sorted
