Feature: Admin Meta Key Definitions

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Setting min & max length
    When I visit "/app_admin/meta_contexts/core/edit"
    And I click on "Edit"
    Then I can see the input with the name "meta_key_definition[length_min]" with no value
    And I can see the input with the name "meta_key_definition[length_max]" with no value
    When I set the input with the name "meta_key_definition[length_min]" to "10"
    And I set the input with the name "meta_key_definition[length_max]" to "64"
    And I submit
    Then I can see a success message
    When I click on "Edit"
    Then I can see the input with the name "meta_key_definition[length_min]" with value "10"
    And I can see the input with the name "meta_key_definition[length_max]" with value "64"

  Scenario: Setting input type
    When I visit "/app_admin/meta_contexts/core/edit"
    And I click on "Edit"
    Then I can see two unchecked radio buttons with the name "meta_key_definition[input_type]"
    When I check the radio button with the name "meta_key_definition[input_type]" with the value "text_area"
    And I submit
    Then I can see a success message
    When I click on "Edit"
    Then I can see checked radio button with the name "meta_key_definition[input_type]" with the value "text_area"
