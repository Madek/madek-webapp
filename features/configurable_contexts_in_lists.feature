Feature: Setting and displaying configurable contexts in list views

  @jsbrowser
  Scenario:  Setting and displaying configurable contexts in list views
    Given I am signed-in as "Adam"
    When I visit my first media_set
    And I click on the link with the id "list-view"
    Then There is not an element with the data-context-name "Institution" in the ui-resource-body
    Then There is not an element with the data-context-name "Landschaftsvisualisierung" in the ui-resource-body
    When I visit the "/app_admin/settings/edit" path 
    And I set the input with the name "app_settings[second_displayed_meta_context_name]" to "Institution"
    And I set the input with the name "app_settings[third_displayed_meta_context_name]" to "Landschaftsvisualisierung"
    And I submit
    Then I can see a success message
    When I visit my first media_set
    And I click on the link with the id "list-view"
    Then There is an element with the data-context-name "Institution" in the ui-resource-body
    Then There is an element with the data-context-name "Landschaftsvisualisierung" in the ui-resource-body


