Feature: Workgroups

  As a MAdeK user
  I want to create/delete groups and edit groupmembers
  So that I can handle groups as subjects

  Background: 
    Given I am signed-in as "Normin"

  @jsbrowser @dirty
  Scenario: Create a new group
    When I go to my groups
     And I try to create a new group by using the context primary action
     And I provide a name
     And I click the primary action of this dialog
    Then the group is created

  @jsbrowser
  Scenario: Requiring name during group creation
    When I go to my groups
     And I try to create a new group by using the context primary action
     And I don't provide a name
     And I click the primary action of this dialog
    Then I see an error that I have to provide a name for that group

  @firefox @dirty
  Scenario: Edit group members
    When I go to my groups
     And I edit one group
    Then I can add a new member to the group
     And I can delete an existing member from the group
    When I click the primary action of this dialog
    Then the group members are updated

  @firefox @dirty
  Scenario: Delete a group
    When I go to my groups
     And I edit one group
     And I remove all members of a specific group except myself
     And I delete that group
    Then the group is deleted
  
  @jsbrowser
  Scenario: Error during group deletion
    When I go to my groups
     And I delete a group where I'm not the only remaining member
    Then I see an error message that the group cannot be deleted if there are more than 1 members
     And the group is not deleted
   
  @jsbrowser @dirty
  Scenario: Successfully edit group name
    When I go to my groups
     And I edit one group
     And I change the group name
     And I click the primary action of this dialog
    Then the group name is changed

   @jsbrowser
   Scenario: Error providing empty group name during edit
    When I go to my groups
     And I edit one group
     And I make the group name empty
     And I click the primary action of this dialog
    Then I see an error message that the group name has to be present
     And the group name is not changed
    