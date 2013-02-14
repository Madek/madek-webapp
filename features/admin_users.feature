Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Creating a new user
    When I navigate to the admin/people interface
    Then I can see at least one link to create a new user
    When I follow the first link to create a new user
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I click the submit input
    Then I can see the text "User wurde erfolgreich erstellt"

  Scenario: Creating a new user with database login
    When I navigate to the admin/people interface
    Then I can see at least one link to create a new user
    When I follow the first link to create a new user
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I set the input with the name "user[password]" to "new_password"
    And I set the usage terms accepted at to next year
    And I click the submit input
    Then I can see the text "User wurde erfolgreich erstellt"
    When I follow the link with the text "Abmelden"
    And I go to the home page
    And I click on the database login tab
    And I set the input with the name "login" to "fritzli"
    And I set the input with the name "password" to "new_password"
    And I click the submit button
    Then I am logged in

  Scenario: Deleting a user
    When I open the admin/users interface
     And I delete a user
    Then I can see the text "User ist zerstört worden"

  Scenario: Editing a user
    When I open the admin/users interface
    And I edit a user
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I set the usage terms accepted at to next year
    And I click the submit input
    Then I can see the text "User wurde aktualisiert"


