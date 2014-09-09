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

  @jsbrowser
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
    When I logout
    And I click on the database login tab
    And I set the input with the name "login" to "fritzli"
    And I set the input with the name "password" to "new_password"
    And I click the submit button
    And I accept the usage terms if I am supposed to do so
    Then I am logged in as "Fritz"

  Scenario: Deleting a user
    When I visit "/app_admin/users"
    And I set the input with the name "filter[search_terms]" to "beat"
    And I click on the button "Apply"
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

  Scenario: Listing users with amount of resources
    When I visit "/app_admin/users"
    Then I see the column with a number of user resources

  Scenario: Sorting users by amount of resources
    When I visit "/app_admin/users"
    And I select "Amount of resources" option from Sort by select
    And I submit
    Then I see user list sorted by amount of resources
    And There is "Amount of resources" sorting option selected

  Scenario: Listing detailed information about user's resources
    When I visit "/app_admin/users"
    And I click on the last "Details" link
    Then I am on a "/app_admin/users/\w+" page
    And I see a table row with "# Media Entries"
    And I see a table row with "# Media Sets"
    And I see a table row with "# Filter Sets"

  Scenario: Searching users by term
    When I visit "/app_admin/users"
    And I set the input with the name "filter[search_terms]" to "KAREN"
    And I submit
    Then I can see only results containing "karen" term

  Scenario: Searching users by term containing leading and trailing spaces
    When I visit "/app_admin/users"
    And I set the input with the name "filter[search_terms]" to " KAren  "
    And I submit
    Then I can see only results containing "karen" term
    And I can see the input with the name "filter[search_terms]" with value "KAren"

  Scenario: Searching and ranking users by text search
    When I visit "/app_admin/users"
    And I set the input with the name "filter[search_terms]" to "kar"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can not see "Karen"
    And I set the input with the name "filter[search_terms]" to "Karen"
    And I select "Text search ranking" option from Sort by select
    And I submit
    Then I can see "Karen"

  Scenario: Searching and ranking users by text search
    When I visit "/app_admin/users"
    And I set the input with the name "filter[search_terms]" to "kar"
    And I select "Trigram search ranking" option from Sort by select
    And I submit
    Then I can see "Karen"

  @jsbrowser
  Scenario: Adding an user to admins
    When I visit "/app_admin/users"
    Then I can see "Knacknuss, Karen"
    When I click on the link "Add to admins"
    Then I can see a success message
    And I can see "Knacknuss, Karen"
    When I visit "/app_admin/admin_users"
    Then I can see "Knacknuss, Karen"
