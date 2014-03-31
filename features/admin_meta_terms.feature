Feature: Admin Meta Terms

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Listing meta terms
    When I visit the admin panel
    Then I can see the "Meta Terms" link in a dropdown with "Meta" label
    When I click on the link "Meta Terms"
    Then I am on the "/app_admin/meta_terms" page
    And I can see the text "MetaTerms"

  Scenario: Editing english & german names
    When I visit "/app_admin/meta_terms"
    Then I can see edit links in a table
    When I click on the first edit link
    Then I am on an edit page
    When I set the input with the name "meta_term[en_gb]" to "umbrella"
    And I set the input with the name "meta_term[de_ch]" to "Regenschirm"
    And I submit
    Then I can see a success message

  Scenario: Deleting unused meta terms
    When I visit "/app_admin/meta_terms"
    Then I can see delete links in a table
    When I click on the first delete link
    Then I can see a success message
    And The meta term does not exist

  Scenario: Sorting by de_ch in ascending order by default
    When I visit "/app_admin/meta_terms"
    Then There is "DE_CH ascending" sorting option selected

  Scenario: Remembering sorting after meta term delete
    When I visit "/app_admin/meta_terms/?sort_by=en_gb_desc"
    And I click on the first delete link
    Then I am on the "/app_admin/meta_terms" page
    And There is "EN_GB descending" sorting option selected

  Scenario: Remembering filtering after meta term delete
    When I visit "/app_admin/meta_terms"
    And I select "Not used" from "filter-by"
    And I submit
    And I click on the first delete link
    Then I can see a success message
    Then I am on the "/app_admin/meta_terms" page
    And There is "Not used" filtering option selected

  Scenario: Remembering search term after meta term delete
    When I visit "/app_admin/meta_terms/?filter_by=not_used&sort_by=text_rank"
    And I set the input with the name "filter[search_terms]" to "title"
    Then I submit
    When I click on the first delete link
    Then I can see a success message
    Then I am on the "/app_admin/meta_terms" page
    And There is the input with name "filter[search_terms]" set to "title"

  @firefox
  Scenario: Searching and ranking meta terms by text search
    When I visit "/app_admin/meta_terms"
    And I set the input with the name "filter[search_terms]" to "tite"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can not see "Titel"
    And I set the input with the name "filter[search_terms]" to "Titel"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can see "Titel"

  @firefox
  Scenario: Searching and ranking meta terms by trigram search
    When I visit "/app_admin/meta_terms"
    And I set the input with the name "filter[search_terms]" to "tite"
    And I select "Trigram search ranking" option from Sort by select
    And I submit
    Then I can see "Titel"

  Scenario: Reseting searching, filtering and sorting
    When I visit "/app_admin/meta_terms/?filter[search_terms]=TERM&filter_by=used&sort_by=en_gb_desc"
    Then There is the input with name "filter[search_terms]" set to "TERM"
    And There is "Used" filtering option selected
    And There is "EN_GB descending" sorting option selected
    When I click on "Reset"
    Then The input with name "filter[search_terms]" is empty
    And There is no filtering option selected
    And There is "DE_CH ascending" sorting option selected

