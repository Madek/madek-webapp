Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Setting a featured set
    When I visit "/app_admin/settings"
    Then I set the input with the name "app_settings[featured_set_id]" to "434c473e-c685-4ea8-83f1-ceebff16c843"
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "app_settings[featured_set_id]" set to "434c473e-c685-4ea8-83f1-ceebff16c843"

  Scenario: Setting a teater set
    When I visit "/app_admin/settings"
    Then I set the input with the name "app_settings[teaser_set_id]" to "e499b452-ed3a-483a-9102-ff6fdb6fb6a5"
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "app_settings[teaser_set_id]" set to "e499b452-ed3a-483a-9102-ff6fdb6fb6a5"

  Scenario: Setting a catalog set
    When I visit "/app_admin/settings"
    Then I set the input with the name "app_settings[catalog_set_id]" to "d2582be1-9180-46f1-93c6-4798de15f615"
    And I submit the form with id "special-sets-form"
    Then I can see a success message
    And There is the input with name "app_settings[catalog_set_id]" set to "d2582be1-9180-46f1-93c6-4798de15f615"

  Scenario: Setting a special set with empty value
    When I visit "/app_admin/settings"
    Then There is the input with name "app_settings[featured_set_id]" set to "d2582be1-9180-46f1-93c6-4798de15f615"
    When I set the input with the name "app_settings[featured_set_id]" to ""
    And I submit the form with id "special-sets-form"
    Then I can see an error message
    And There is the input with name "app_settings[featured_set_id]" set to "d2582be1-9180-46f1-93c6-4798de15f615"

  Scenario: Setting a special set with the same id
    When I visit "/app_admin/settings"
    Then There is the input with name "app_settings[featured_set_id]" set to "d2582be1-9180-46f1-93c6-4798de15f615"
    And I submit the form with id "special-sets-form"
    Then I can see a notice with message "The special sets have not been updated."
    And There is the input with name "app_settings[featured_set_id]" set to "d2582be1-9180-46f1-93c6-4798de15f615"
