
Feature: Editing keywords, people, controlled vocabularies...

  @jsbrowser
  Scenario: Changing all meta-data fields of a media entry
    Given I am signed-in as "Normin"
     When I go to the edit-page of my first media_entry
     And I change the value of each meta-data field of each context
     And I click on the button "Speichern"
     Then I am on the page of my first media_entry
     And I can see every meta-data-value somewhere on the page
     When I go to the edit-page of my first media_entry
     Then each meta-data value in each context should be equal to the one set previously

  @jsbrowser
  Scenario: Adding a new person as the author
    Given I am signed-in as "Normin"
    When I go to the edit-page of my first media_entry
    And I delete all existing authors
    And I click on the icon of the author fieldset
    And I set the input with the name "last_name" to "Turner"
    And I set the input with the name "first_name" to "William"
    And I set the input with the name "pseudonym" to "Willi"
    And I click on the button "Person einfügen"
    And I wait for multi-select-tag with the text "Turner, William (Willi)"
    And I click on the button "Speichern"
    Then I am on the page of my first media_entry
    And I can see the text "Turner, William (Willi)"

  @jsbrowser 
  Scenario: Adding a new group as the author
    Given I am signed-in as "Normin"
    When I go to the edit-page of my first media_entry
    And I delete all existing authors
    And I click on the icon of the author fieldset
    And I click on the link "Gruppe" 
    And I set the input with the name "first_name" to "El grupo"
    And I click on the button "Gruppe einfügen"
    And I wait for multi-select-tag with the text "El grupo [Gruppe]"
    And I click on the button "Speichern"
    Then I am on the page of my first media_entry
    And I can see the text "El grupo [Gruppe]"

  @jsbrowser 
  Scenario: License: selecting an individual license clears presets
    Given I am signed-in as "Normin"
    When I go to the edit-page of my first media_entry
    And I click on the link "Credits"
    And I click on the link "Weitere Angaben"
    And I select "Public Domain" from "copyright-roots"
    Then the textarea within the fieldset "copyright usage" is not empty
    And the textarea within the fieldset "copyright url" is not empty
    And I select "individuelle Lizenz" from "copyright-roots"
    Then the textarea within the fieldset "copyright usage" is empty
    Then the textarea within the fieldset "copyright url" is empty
    When I try to leave the page
    Then I have to confirm

  @firefox 
  Scenario: Show warning before leaving media entry edit page and losing unsaved data
    Given I am signed-in as "Normin"
    When I go to the edit-page of my first media_entry
    And I change some input field
    And I try to leave the page
    Then I see a warning that I will lose unsaved data
    And I have to confirm
    Then I am able to leave the page

  @firefox 
  Scenario: Show warning before leaving media entry multiple edit page (batch) and losing unsaved data
    Given I am signed-in as "Normin"
    When I go to edit multiple media entries using the batch
    And I change some input field
    And I try to leave the page
    Then I see a warning that I will lose unsaved data
    And I have to confirm
    Then I am able to leave the page
