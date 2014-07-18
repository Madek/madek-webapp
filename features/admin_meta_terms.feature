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

  Scenario: Transferring resources to another meta term
    When I visit "/app_admin/meta_terms?utf8=%E2%9C%93&filter_by=used"
    And I see the count of resources associated to each meta term
    When a meta term has some resources associated to it
    And I move all resources from that meta term to another meta term
    Then I am redirected to the admin meta term list
    Then the origin meta term has no resources to transfer

  Scenario: Editing term value
    When I visit "/app_admin/meta_terms"
    Then I can see edit links in a table
    When I click on the first edit link
    Then I am on an edit page
    When I set the input with the name "meta_term[term]" to "umbrella"
    And I submit
    Then I can see a success message

  Scenario: Sorting by term in ascending order by default
    When I visit "/app_admin/meta_terms"
    Then There is "ascending" sorting option selected

  @firefox
  Scenario: Searching and ranking meta terms by text search
    When I visit "/app_admin/meta_terms"
    And I set the input with the name "filter[search_terms]" to "tur"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can not see "Turm"
    And I set the input with the name "filter[search_terms]" to "Turm"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can see "Turm"

  @firefox
  Scenario: Searching and ranking meta terms by trigram search
    When I visit "/app_admin/meta_terms"
    And I set the input with the name "filter[search_terms]" to "tur"
    And I select "Trigram search ranking" option from Sort by select
    And I submit
    Then I can see "Turm"

  Scenario: Reseting searching, filtering and sorting
    When I visit "/app_admin/meta_terms/?filter[search_terms]=TERM&filter_by=used&sort_by=desc"
    Then There is the input with name "filter[search_terms]" set to "TERM"
    And There is "Used" filtering option selected
    And There is "descending" sorting option selected
    When I click on "Reset"
    Then The input with name "filter[search_terms]" is empty
    And There is no filtering option selected
    And There is "ascending" sorting option selected

  Scenario: Deleting unused meta term
    When I visit "/app_admin/meta_terms"
    And Delete unused meta term
