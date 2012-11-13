Feature: Admin interface 

  As a MAdeK admin

  Background: Load the example data and personas
      Given I am "Adam"

  @javascript
  Scenario: Changing MetaData to a person 
    When I open the admin interface
     And I navigate to the people list
    Then for each person I see the id
     And I see the count of MetaData associated to each person
    When a person has some MetaData associated to it
     And I edit that person
     And I move all MetaData from that person to another person 
     And I navigate to the people list
    Then the count of MetaData associated to that person is 0

  @javascript
  Scenario: Delete a person
    When I open the admin interface
     And I navigate to the people list
    When a person does not have any MetaData associated to it
    Then I can delete that person
    When I delete the person
    Then the person is deleted

  @javascript
  Scenario: Prevent deleting people that have metadata 
    When I open the admin interface
     And I navigate to the people list
    When a person has some MetaData associated to it
    Then I can not delete that person
