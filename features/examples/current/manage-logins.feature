Feature: Managing Logins

  As a MAdeK admin

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Adam"

  Scenario: Create a new database login
    When I open the admin interface
     And I navigate to the people list
     And I see if there is already an associated user (Edit/Add User)
    When I create a new person
     And I fill in lastname, firstname and pseudonym
     And I create a new user for that person
     And I fill in login, email, password and comment
    Then a new user is created 
     And a database login is created
     And the password is crypted

  Scenario: Edit a user
     When I open the admin interface
      And I switch to the user list
      And I edit the user
     When I change login, email, password and comment
     Then the login, email, password and comment are changed

  Scenario: Delete a user
    When I open the admin interface
     And I switch to the user list
     And I delete a user
    Then the user is deleted

