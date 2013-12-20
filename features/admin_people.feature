Feature: Admin interface 

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Changing MetaData to a person 
    When I visit "/app_admin/people?utf8=%E2%9C%93&%5Bfuzzy_search%5D=&with_meta_data=1" 
    Then for each person I see the id
     And I see the count of MetaData associated to each person
    When a person has some MetaData associated to it
     And I move all MetaData from that person to another person 
    Then I am redirected to the admin people list
    Then the origin person has not meta_data to transfer

  @jsbrowser
  Scenario: Delete a person
    When I navigate to the app_admin/people interface
    When a person does not have any MetaData neither User associated to it
    And I set the input with the name "[fuzzy_search]" to persons last name
    And I submit
    Then I can delete that person
    When I delete the person
    Then the person is deleted

  Scenario: Prevent deleting people that have metadata 
    When I navigate to the app_admin/people interface
    When a person has some MetaData associated to it
    Then I can not delete that person
