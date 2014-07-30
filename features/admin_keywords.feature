Feature: Admin Keywords

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Listing keywords
    When I visit the admin panel
    Then I can see the "Keywords" link in a dropdown with "Meta" label
    When I click on the link "Keywords"
    Then I am on the "/app_admin/keywords" page
    And I can see the text "Keywords"

  Scenario: Transferring media entries to another keyword
    When I visit "/app_admin/keywords?sort_by=used_times_desc"
    And A keyword has some resources associated to it
    And I move all resources from that keyword to another keyword
    Then I can see a success message
    Then The origin keyword has no resources to transfer

  Scenario: Editing term value
    When I visit "/app_admin/keywords"
    Then I can see edit links in a table
    When I click on the first edit link
    Then I am on an edit page
    When I set the input with the name "keyword[term]" to "TERM"
    And I submit
    Then I can see a success message
    And I can see the text "TERM"

  Scenario: Searching keywords
    When I visit "/app_admin/keywords"
    And I set the input with the name "search_term" to "sq6"
    And I submit
    Then I can see only results containing "sq6" term
    When I set the input with the name "search_term" to "SQ"
    And I submit
    Then I can see only results containing "sq6" term

  @firefox
  Scenario: Searching and ranking keywords by text search
    When I visit "/app_admin/keywords"
    And I set the input with the name "search_term" to "wolke"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can not see "Wolken"
    And I set the input with the name "search_term" to "wolken"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can see "Wolken"

  @firefox
  Scenario: Searching and ranking keywords by trigram search
    When I visit "/app_admin/keywords"
    And I set the input with the name "search_term" to "wolke"
    And I select "Trigram search ranking" option from Sort by select
    And I submit
    Then I can see "Wolken"

  Scenario: Reseting searching, filtering and sorting
    When I visit "/app_admin/keywords/?search_term=TERM&sort_by=used_times_desc"
    Then There is the input with name "search_term" set to "TERM"
    And There is "Used times (descending)" sorting option selected
    When I click on "Reset"
    Then The input with name "search_term" is empty
    And There is "Created at (descending)" sorting option selected
