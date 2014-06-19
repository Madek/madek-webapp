Feature: Setting and displaying configurable contexts in list views

  @jsbrowser
  Scenario:  Setting and displaying configurable contexts in list views
    Given I am signed-in as "Adam"
    When I visit "/media_sets/b23c6f19-4fdd-4e7d-b48e-697953fe5f12"
    And I click on the link with the id "list-view"
    Then There is not an element with the data-context-id "Institution" in the ui-resource-body
    Then There is not an element with the data-context-id "Landschaftsvisualisierung" in the ui-resource-body
    When I visit the "/app_admin/settings/second_displayed_context_id/edit" path 
    And I set the input with the name "app_settings[second_displayed_meta_context_id]" to "Institution"
    And I submit
    When I visit the "/app_admin/settings/third_displayed_context_id/edit" path
    And I set the input with the name "app_settings[third_displayed_meta_context_id]" to "Landschaftsvisualisierung"
    And I submit
    Then I can see a success message
    When I visit "/media_sets/b23c6f19-4fdd-4e7d-b48e-697953fe5f12"
    And I click on the link with the id "list-view"
    Then There is an element with the data-context-id "Institution" in the ui-resource-body
    Then There is an element with the data-context-id "Landschaftsvisualisierung" in the ui-resource-body


