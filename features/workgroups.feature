Feature: Workgroups

  As a MAdeK user
  I want to create/delete groups and edit groupmembers
  So that I can handle groups as subjects

  Background: 
    Given I am signed-in as "Normin"

  @firefox
  Scenario: Create a new group
    When I go to my groups
     And I click on "Neue Arbeitsgruppe"
     And I wait for 2 seconds
     And I provide a name
     And I click the primary action of this dialog
    Then the group is created

  @firefox
  Scenario: Requiring name during group creation
    When I go to my groups
     And I click on "Neue Arbeitsgruppe"
     And I wait for 2 seconds
     And I don't provide a name
     And I click the primary action of this dialog
    Then I see an error that I have to provide a name for that group

  @jsbrowser
  Scenario: Edit group members
    When I go to my groups
     And I edit one group
     And I wait for 2 seconds
    Then I can add a new member to the group
     And I can delete an existing member from the group
     And I execute JavaScript "$('.modal.in').find('.ui-modal-body').css('max-height', 0)"
    When I click the primary action of this dialog
    Then the group members are updated

  @firefox
  Scenario: Delete a group
    When I go to my groups
     And I edit one group
     And I remove all members of a specific group except myself
     And I wait for 2 seconds
     And I delete that group
    Then the group is deleted

  @firefox
  Scenario: Error during group deletion
    When I go to my groups
     And I delete a group where I'm not the only remaining member
    Then I see an error message that the group cannot be deleted if there are more than 1 members
     And the group is not deleted

  @firefox
  Scenario: Successfully edit group name
    When I go to my groups
     And I edit one group
     And I wait for 2 seconds
     And I change the group name
     And I wait for 2 seconds
     And I execute JavaScript "$('.modal.in').find('.ui-modal-body').css('max-height', 0)"
     And I click the primary action of this dialog
    Then the group name is changed

  @firefox
  Scenario: Error providing empty group name during edit
    When I go to my groups
     And I edit one group
     And I wait for 2 seconds
     And I make the group name empty
     And I execute JavaScript "$('.modal.in').find('.ui-modal-body').css('max-height', 0)"
     And I click the primary action of this dialog
    Then I see an error message that the group name has to be present
     And the group name is not changed
