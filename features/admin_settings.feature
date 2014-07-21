Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  @firefox
  Scenario: Setting a special set
    When I visit "/app_admin/settings"
    And I set the autocomplete-input with the name "featured_set_id" to "bei"
    And I click on "Beispiele1" inside the autocomplete list
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "featured_set_id" set to "Beispiele1"

  Scenario: Setting a special set with empty value
    When I visit "/app_admin/settings"
    Then There is the input with name "featured_set_id" set to "Beispielhafte-Sets"
    When I set the input with the name "featured_set_id" to ""
    And I submit
    Then I can see a notice with message "The special sets have not been updated."
    And There is the input with name "featured_set_id" set to "Beispielhafte-Sets"
