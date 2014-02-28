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
