Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  @firefox
  Scenario: Setting a featured set
    When I visit "/app_admin/settings"
    And I set the autocomplete-input with the name "featured_set_id" to "bei"
    And I click on "Beispiele1" inside the autocomplete list
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "featured_set_id" set to "Beispiele1"

  @firefox
  Scenario: Setting a teater set
    When I visit "/app_admin/settings"
    And I set the autocomplete-input with the name "teaser_set_id" to "ben"
    And I click on "Abgaben" inside the autocomplete list
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "teaser_set_id" set to "Abgaben"

  @firefox
  Scenario: Setting a special set
    When I visit "/app_admin/settings"
    And I set the autocomplete-input with the name "catalog_set_id" to "ipl"
    And I click on "Diplomarbeiten" inside the autocomplete list
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "catalog_set_id" set to "Diplomarbeiten"

  Scenario: Setting a special set with empty value
    When I visit "/app_admin/settings"
    Then There is the input with name "featured_set_id" set to "Beispielhafte-Sets"
    When I set the input with the name "featured_set_id" to ""
    And I submit
    Then I can see a notice with message "The special sets have not been updated."
    And There is the input with name "featured_set_id" set to "Beispielhafte-Sets"
