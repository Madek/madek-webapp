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
