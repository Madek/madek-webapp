Feature: Managing Permission Presets

  As a MAdeK admin

  Background:
    Given I am signed-in as "Adam"

  Scenario: Creating new permission preset
    When I visit "/app_admin/permission_presets"
    And I click on "New permission preset"
    And I set the input with the name "permission_preset[name]" to "New preset"
    And I check a checkbox with name "permission_preset[edit]"
    And I check a checkbox with name "permission_preset[view]"
    And I submit
    Then I can see a success message
    
  Scenario: Editing a permission preset
    When I visit "/app_admin/permission_presets"
    And I click on "Edit"
    And I set the input with the name "permission_preset[name]" to "New preset"
    And I submit
    Then I can see a success message
  
  @jsbrowser
  Scenario: Changing permission preset position
    When I visit "/app_admin/permission_presets"
    And I click on the first arrow down
    Then I can see permission preset to move down
