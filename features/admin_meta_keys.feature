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
    When I set the input with the name "filter[label]" to "identifier"
    And I submit
    Then I can see only meta keys containing "identifier" term
    And I can see the input with the name "filter[label]" with value "identifier"

  Scenario: Filtering meta keys by label related to a context
    When I visit "/app_admin/meta_keys"
    And I set the input with the name "filter[label]" to "Titel"
    And I submit
    Then I can see only meta keys containing "Titel des Werks" term
    And I can see only meta keys containing "Titel" term 

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

  Scenario: Adding a meta term with aplhabetical order
    When I visit "/app_admin/meta_keys/type/edit"
    Then There is "alphabetical order" option selected in "meta_key[meta_terms_alphabetical_order]" select
    When I set the input for a new meta term to "A"
    And I submit
    Then I can see a success message
    And The meta term is at the top of the list

  Scenario: Adding a meta term with thematic order
    When I visit "/app_admin/meta_keys/type/edit"
    And I select "thematic order" from the select node with the name "meta_key[meta_terms_alphabetical_order]"
    And I set the input for a new meta term to "A"
    And I submit
    Then I can see a success message
    And The meta term is at the end of the list

  Scenario: Applying alphabetical order to meta terms
    When I visit "/app_admin/meta_keys/type/edit"
    And I add a meta term with thematic order
    Then The meta term is at the end of the list
    When I select "alphabetical order" from the select node with the name "meta_key[meta_terms_alphabetical_order]"
    And I submit
    Then The meta term is at the top of the list

  Scenario: Merging a meta term to another one
    When I visit "/app_admin/meta_keys/LV_Wetter@Klima/edit"
    Then I can see the "Gewitter" meta term on the list
    And I can see the "Morgenrot" meta term on the list
    When I merge "Gewitter" meta term to "Morgenrot"
    Then There is only one "Morgenrot" meta term on the list
    And I can not see the "Gewitter" meta term on the list

  Scenario: Merging a meta term by giving an id with whitespaces
    When I visit "/app_admin/meta_keys/type/edit"
    And I set the input with the name "reassign_term_id[9a51b344-ce70-420d-8f16-9974b6afdb4c]" to " 6b443b98-4297-499e-9964-4492f0be41ee  "
    And I submit
    Then I can see a success message

  Scenario: Changing type from MetaDatumString to MetaDatumMetaTerms
    When I visit "/app_admin/meta_keys/subtitle/edit"
    Then There is "MetaDatumString" option selected in "meta_key[meta_datum_object_type]" select
    When I change the type of the meta key to MetaDatumMetaTerms
    Then I am on a "/app_admin/meta_keys/subtitle/edit" page
    And I can see a success message
    And I can see "Terms"
    And There is "alphabetical order" option selected in "meta_key[meta_terms_alphabetical_order]" select
