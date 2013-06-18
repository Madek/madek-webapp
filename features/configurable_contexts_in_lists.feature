Feature: Setting and displaying configurable contexts in list views

  @jsbrowser 
  Scenario:  Setting and displaying configurable contexts in list views
    Given I am signed-in as "Adam"
    When I visit the "/app_admin/settings/edit" path 
    And I set the input with the name "app_settings[second_displayed_meta_context_name]" to "Institution"
    And I set the input with the name "app_settings[third_displayed_meta_context_name]" to "Landschaftsvisualisierung"
    And I submit
    Then I can see a success message
    When I visit "/media_sets/101?layout=list"
    Then There is a element with the data-context-name "Institution" in the ui-resource-body
    Then There is a element with the data-context-name "Landschaftsvisualisierung" in the ui-resource-body



    






