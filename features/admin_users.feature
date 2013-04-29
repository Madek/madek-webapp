Feature: Managing Users and Logins

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Creating a new user with person 
    When I visit "/app_admin/users"
    And I click on the link "New user with person"
    And I set the input with the name "person[last_name]" to "Fischer"
    And I set the input with the name "person[first_name]" to "Fritz"
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I set the input with the name "user[password]" to "new_password"
    And I submit 
    Then I can see a success message

  Scenario: Creating a new user for an existing person 
    When I visit "/app_admin/users"
    And I click on the link "New user for existing person"
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I set the input with the name "user[password]" to "new_password"
    And I set the input with the name "user[person_id]" to the id of a newly created person
    And I submit 
    Then I can see a success message

  Scenario: Loging-in as a newly created user 
    When I visit "/app_admin/users"
    And I click on the link "New user with person"
    And I set the input with the name "person[last_name]" to "Fischer"
    And I set the input with the name "person[first_name]" to "Fritz"
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I set the input with the name "user[password]" to "new_password"
    And I submit 
    Then I can see a success message
    When I visit "/logout"
    And I go to the home page
    And I click on the database login tab
    And I set the input with the name "login" to "fritzli"
    And I set the input with the name "password" to "new_password"
    And I click the submit button
    Then I am logged in

  Scenario: Deleting a user
    When I visit "/app_admin/users"
    And I set the input with the name "filter[fuzzy_search]" to "beat"
    And I click on the button "Filter"
    And I click on the link "Details"
    And I click on "Destroy"
    Then I can see a success message

  Scenario: Editing a user
    When I visit "/app_admin/users"
    And I click on the link "Details"
    And I click on the link "Edit"
    And I set the input with the name "user[login]" to "fritzli"
    And I set the input with the name "user[email]" to "fritzli@zhdk.ch"
    And I submit
    Then I can see a success message


