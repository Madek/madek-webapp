Feature: Admin interface 

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Changing MetaData to a person 
    When I visit "/app_admin/people?utf8=%E2%9C%93&with_meta_data=1" 
     And I see the count of MetaData associated to each person
    When a person has some MetaData associated to it
     And I move all MetaData from that person to another person 
    Then I am redirected to the admin people list
    Then the origin person has not meta_data to transfer

  @jsbrowser
  Scenario: Delete a person
    When I navigate to the app_admin/people interface
    When a person does not have any MetaData neither User associated to it
    And I set the input with the name "filter[search_terms]" to persons last name
    And I submit
    Then I can delete that person
    When I delete the person
    Then the person is deleted

  Scenario: Prevent deleting people that have metadata 
    When I navigate to the app_admin/people interface
    When a person has some MetaData associated to it
    Then I can not delete that person

  Scenario: Editing person
    When I visit "/app_admin/people"
    And I click on "Edit"
    And I set the input with the name "person[last_name]" to "LAST_NAME"
    And I set the input with the name "person[first_name]" to "FIRST_NAME"
    And I set the input with the name "person[pseudonym]" to "PSEUDONYM"
    And I set the input with the name "person[date_of_birth]" to "10.04.1989"
    And I submit
    Then I can see a success message
    And I can see "LAST_NAME"
    And I can see "FIRST_NAME"
    And I can see "PSEUDONYM"
    And I can see "1989-04-10"

  Scenario: Default sorting
    When I visit "/app_admin/people"
    Then There is "Last-, first-name" sorting option selected
    And There is "Admin" at the top of the list

  Scenario: Sorting by date of creation
    When I visit "/app_admin/people"
    And I select "Date of creation" from the select node with the name "sort_by"
    And I submit
    Then There is "Pape" at the top of the list

  Scenario: Searching people
    When I visit "/app_admin/people"
    And I set the input with the name "filter[search_terms]" to "ann"
    And I submit
    Then I can see only results containing "ann" term

  Scenario: Searching people by term containing leading and trailing spaces
    When I visit "/app_admin/people"
    And I set the input with the name "filter[search_terms]" to "  ann "
    And I submit
    Then I can see only results containing "ann" term
    And I can see the input with the name "filter[search_terms]" with value "ann"
