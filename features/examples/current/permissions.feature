
# See also the sketch at:
# https://www.pivotaltracker.com/story/show/23669443
#
#Berechtigungen:
#Es gibt folgende Berechtigungen auf Ressourcen im Medienarchiv (In Klammer die deutschen Bezeichnungen des Interfaces):
#- View (Sehen): sehen einer Ressource
#- Edit (Editieren): editieren von Metadaten einer Ressource, hinzufügen und wegnehmen von Ressourcen zu einem Set
#- Download Original (Exportieren des Originals): Exportieren des originalen Files
#- Manage permissions: Verwalten der Berechtigungen auf einer Ressource
#- Ownership: Person, die eine Ressource importiert/erstellt hat, hat defaultmässig die Ownership und alle obigen Berechtigungen.
#- Nennt man eine Person oder eine Gruppe bei den Berechtigungen, wählt für diese aber keine Berechtigungen aus, so bedeutet dies, dass den genannten explizit die Berechtigungen entzogen sind.


Feature: Permissions
  As the user "Susanne Schumacher"
  I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

#  Background: Load the example data and personas
#	Given I have set up the world
#    And personas are loaded
#    And I am "Normin"

  Scenario: View permission
    Given a resource owned by "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |view             |true |
     Then "Normin" can view the resource

  Scenario: Edit permission
    Given a resource owned by "Susanne Schumacher"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|edit             |yes  |
     Then "Susanne Schumacher" can edit the resource

  Scenario: Download original permission
    Given a resource owned by "Susanne Schumacher"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|download original|yes  |
     Then "Susanne Schumacher" can download the original file of the resource

  Scenario: Manage permission
    Given a resource owned by "Susanne Schumacher"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|manage           |yes  |
     Then "Susanne Schumacher" can manage permissions on the resource

  Scenario: Owner permission
    Given a resource owned by "Susanne Schumacher"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|owner            |yes  |
     Then "Susanne Schumacher" can the owner of the resource

  # We can add things to a set if we have "view" on the thing we want to add and "edit"
  # on the thing we are adding it to.
  Scenario: Permission to add things to a set
    Given a set called "Editable Set" owned by "Susanne Schumacher"
      And the set has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|edit             |yes  |
      And a set called "Viewable Set" owned by "Ramon Cahenzli"
      And the set has the following permissions:
      |user              |permission       |value|
      |Susanne Schumacher|view             |yes  |
     When "Susanne Schumacher" adds "Viewable Set" to "Editable Set"
     Then "Editable Set" is in "Viewable Set"

  Scenario: Group permissions
    Given a group called "MAdeK Managers" with the following members:
    |user              |
    |Susanne Schumacher|
    |Ramon Cahenzli    |
    And a resource owned by "Susanne Schumacher"
    And the resource has the following permissions:
    |user              |permission       |value|
    |MAdeK Managers    |view             |yes  |
    |MAdeK Managers    |edit             |yes  |
    |MAdeK Managers    |manage           |yes  |
    Then "Susanne Schumacher" can edit the resource
     And "Ramon Cahenzli" can edit the resource
     And "Susanne Schumacher" can manage permissions on the resource
     And "Ramon Cahenzli" can manage permissions on the resource
     And "Susanne Schumacher" can view the resource
     And "Ramon Cahenzli" can view the resource

   Scenario: People without permissions are explicitly excluded even when they would have group permissions
    Given a group called "MAdeK Managers" with the following members:
    |user              |
    |Susanne Schumacher|
    |Ramon Cahenzli    |
    And a resource owned by "Susanne Schumacher"
    And the resource has the following permissions:
    |user              |permission       |value|
    |MAdeK Managers    |view             |yes  |
    |MAdeK Managers    |edit             |yes  |
    |MAdeK Managers    |manage           |yes  |
    |Ramon Cahenzli    |manage           |no|
    |Ramon Cahenzli    |view             |no|
    |Ramon Cahenzli    |edit             |no|
    Then "Susanne Schumacher" can edit the resource
     And "Ramon Cahenzli" can not edit the resource
     And "Susanne Schumacher" can manage permissions on the resource
     And "Ramon Cahenzli" can not manage permissions on the resource
     And "Susanne Schumacher" can view the resource
     And "Ramon Cahenzli" can not view the resource   
