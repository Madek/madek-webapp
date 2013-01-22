Feature: Workgroups

  As a MAdeK user
  I want to create/delete groups and edit groupmembers
  So that I can handle groups as subjects

  Scenario: Create a new group
    When I go to my groups
     And I try to create a new group by using the context primary action
     And I provide a name
    Then the group is created

  Scenario: Requiring name during group creation
    When I go to my groups
     And I try to create a new group by using the context primary action
     And I don't provide a name
    Then I see an error that I have to provide a name for that group

  Scenario: Edit group members
    When I go to my groups
     And I edit one group
    Then I can add a new member to the group
     And I can delete an existing member from the group

  Scenario: Delete a group
    When I go to my groups
     And I remove all members of a specific group except myself
     And I delete that group
    Then the group is deleted
     
  Scenario: Error during group deletion
    When I go to my groups
     And I delete a group where I'm not the only remaining member
    Then I see an error message that the group cannot be deleted if there are more than 1 members
     And the group is not deleted
     
  Scenario: Edit group names
    When I go to my groups
     And I edit one group
    Then I can change the group's name
     And I cannot leave the group's name empty 