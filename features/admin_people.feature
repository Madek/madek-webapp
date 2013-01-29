Feature: Admin interface 

  As a MAdeK admin

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Changing MetaData to a person 
    When I navigate to the admin/people interface
    Then for each person I see the id
     And I see the count of MetaData associated to each person
    When a person has some MetaData associated to it
     And I move all MetaData from that person to another person 
    Then I am redirected to the admin people list
    Then the origin person has not meta_data to transfer

  Scenario: Delete a person
    When I navigate to the admin/people interface
    When a person does not have any MetaData neither User associated to it
    Then I can delete that person
    When I delete the person
    Then the person is deleted

  Scenario: Prevent deleting people that have metadata 
    When I navigate to the admin/people interface
    When a person has some MetaData associated to it
    Then I can not delete that person
