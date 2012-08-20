Feature: Managing Logins

  As a MAdeK admin

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Adam"

  @javascript
  Scenario: Create a new database login
    When I open the admin interface
     And I navigate to the people list
     And I see if there is already an associated user (Edit/Add User)
    When I create a new person
     And I fill in the following:
      | person_firstname   | Paul    |
      | person_lastname    | Hewson  |
      | person_pseudonym   | Bono    |
     And I press "Update"
     And I create a new user for "Bono"
     And I fill in the following:
      | user_login                  | bono             |
      | user_email                  | bono@u2band.com  |
      | user_password               | u2bono           |
      | user_password_confirmation  | u2bono           |
      | user_notes                  | external user    |
     And I press "Create"
    When I see if there is already an associated user (Edit/Add User)
    Then a new user with login "bono" is created 
     And a database login is created
     And the password is crypted

  Scenario: Edit a user
     When I open the admin interface
      And I navigate to the users list
      And I edit the user
     When I change login, email, password and comment
     Then the login, email, password and comment are changed

  Scenario: Delete a user
    When I open the admin interface
     And I navigate to the users list
     And I delete a user
    Then the user is deleted

