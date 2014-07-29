Feature: Managing Media-Entries

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Listing media sets
    When I visit the admin panel
    Then I can see the "Media Entries" link in a dropdown with "Media Resources" label
    And I click on the link "Media Entries"
    Then I am on the "/app_admin/media_entries" page
    And I can see the text "Media Entries"

  Scenario: Filtering by id
    When I visit "/app_admin/media_entries"
    Then I can see the input with the name "filter[search_term]" with no value
    When I set the input with the name "filter[search_term]" to "cb655264-6fa5-4a7e-bfbe-8f1404ee6323" and submit
    Then I can see only results containing "cb655264-6fa5-4a7e-bfbe-8f1404ee6323" term
    And I can see the input with the name "filter[search_term]" with value "cb655264-6fa5-4a7e-bfbe-8f1404ee6323"

  Scenario: Filtering by custom url
    When I visit "/app_admin/media_entries"
    And I filter media entries with custom url

  Scenario: Filtering by title
    When I visit "/app_admin/media_entries"
    And I set the input with the name "filter[search_term]" to "in my head" and submit
    Then I can see only results containing "Shit in my Head" term

  Scenario: Filtering by term with leading and trailing whitespaces
    When I visit "/app_admin/media_entries"
    And I set the input with the name "filter[search_term]" to " in my head  " and submit
    Then I can see only results containing "Shit in my Head" term
