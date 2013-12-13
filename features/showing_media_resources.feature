Feature: Showing resources in the archive

  @jsbrowser
  Scenario: Displaying resources in a FilterSet that includes all public entries
    Given I am signed-in as "Normin"
    And I visit "/filter_sets/111"
    Then I can see at least "3" included resources
    When I click on the clickable with text "Medieneinträge" and with the value "media_entries" for the attribute "data-type"
    Then I can see at least "3" included resources
    When I click on the clickable with text "Sets" and with the value "sets" for the attribute "data-type"
    Then I can see at least "3" included resources

  @jsbrowser
  Scenario: Displaying resources in a MediaSet that inclues a Set, FilterSet and an Entry
    Given I am signed-in as "Normin"
    And I visit "/media_sets/112"
    Then I can see exactly "3" included resources
    When I click on the clickable with text "Medieneinträge" and with the value "media_entries" for the attribute "data-type"
    Then I can see exactly "1" included resources
    When I click on the clickable with text "Sets" and with the value "sets" for the attribute "data-type"
    Then I can see exactly "2" included resources

  @firefox
  Scenario: Watching a movie as a guest
    Given There is a movie with previews and public viewing-permission
    When I visit the page of that movie
    And I can see the preview
    And I can watch the video


