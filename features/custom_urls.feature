Feature: Setting and using custom URLs for MediaResources

  Background: Creating a URL and setting it as the primary url
 
  @jsbrowser
  Scenario: Creating a URL
    Given I am signed-in as "Normin"
    When I visit my first media_entry 
    And I click on "Weitere Aktionen"
    And I click on "URLs"
    Then I can see "URLs für"
    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit
    Then I can see a success message
    Then I can see "the_new_url_for_testing"
    When I click on "the_new_url_for_testing"
    Then I am on a "media_entries" page

  @jsbrowser
  Scenario: Defining and redirection to the primary url
    Given I am signed-in as "Normin"
    When I visit my first media_entry 
    And I remember the path 
    And I click on "Weitere Aktionen"
    And I click on "URLs"

    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit

    When I click on "the_new_url_for_testing"
    Then I am on a "media_entries" page
    And The current_path is equal to the remembered one

    When I click on "Weitere Aktionen"
    And I click on "URLs"
    And I can see the text "Weiterleitung" inside the node with the id "the_new_url_for_testing"
    And I click on "Als primäre URL setzen" inside the node with the id "the_new_url_for_testing"
    Then I can see a success message
    And I can see the text "Primäre URL" inside the node with the id "the_new_url_for_testing"
    When I click on "the_new_url_for_testing"
    Then I am on a "media_entries" page
    And The current_path matches "the_new_url_for_testing"

    When I click on "Weitere Aktionen"
    And I click on "URLs"
    And I click on the first link inside the node with the id "_uuid"
    And The current_path matches "the_new_url_for_testing"


  @jsbrowser
  Scenario: Transfering URL and redirection from '/media_resources/...')

    # we use the different urls for sets / entries to check redirection

    Given I am signed-in as "Normin"

    When I visit my first media_entry 
    And I remember the path 
    And I click on "Weitere Aktionen"
    And I click on "URLs"
    And I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit
    And I can see the text "Weiterleitung" inside the node with the id "the_new_url_for_testing"
    And I click on "Als primäre URL setzen" inside the node with the id "the_new_url_for_testing"
    Then I can see a success message
    And I can see the text "Primäre URL" inside the node with the id "the_new_url_for_testing"

    When I click on "the_new_url_for_testing"
    Then The current_path matches "media_entries/the_new_url_for_testing"

    When I visit "/media_resources/the_new_url_for_testing"
    Then The current_path matches "media_entries/the_new_url_for_testing"

    When I visit my first media_set
    And I click on "Weitere Aktionen"
    And I click on "URLs"
    And I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit
    Then I can see "URL Transfer Bestätigen"

    When I click on "URL übertragen"
    Then I can see a success message
    And I click on "Als primäre URL setzen" inside the node with the id "the_new_url_for_testing"
    Then I can see a success message

    When I visit "/media_resources/the_new_url_for_testing"
    Then The current_path matches "media_sets/the_new_url_for_testing"


  @jsbrowser 
  Scenario: Creating URLs too quickly for one media_resource is not allowed
    Given I am signed-in as "Normin"
    When I visit my first media_entry 
    And I click on "Weitere Aktionen"
    And I click on "URLs"
    Then I can see "URLs für"
    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit
    Then I can see a success message
    Then I can see "the_new_url_for_testing"

    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "a_second_url_for_testing"
    And I submit
    Then I can see a error message
    And The input with the id "url" has the value "a_second_url_for_testing"

  @jsbrowser
  Scenario: Creating URLs quickly as a Ueberadmin
    Given I am signed-in as "Adam"
    And I remember a media_entry that doesn't belong to me, has no public, nor other permissions
    When I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln" 
    And I visit the media_entry
    And I click on "Weitere Aktionen"
    And I click on "URLs"
    Then I can see "URLs für"
    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "the_new_url_for_testing"
    And I submit
    Then I can see a success message
    Then I can see "the_new_url_for_testing"
    When I click on "the_new_url_for_testing"
    Then I am on a "media_entries" page

    When I click on "Weitere Aktionen"
    And I click on "URLs"
    When I click on "Neue URL anlegen"
    And I set the input with the name "url" to "a_second_url_for_testing"
    And I submit
    Then I can see a success message
    Then I can see "a_second_url_for_testing"

