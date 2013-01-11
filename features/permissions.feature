Feature: Permissions
  As a user
  I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

#Berechtigungen:
#Es gibt folgende Berechtigungen auf Ressourcen im Medienarchiv (In Klammer die deutschen Bezeichnungen des Interfaces):
#- View (Sehen): sehen einer Ressource
#- Edit (Editieren): editieren von Metadaten einer Ressource, hinzufügen und wegnehmen von Ressourcen zu einem Set
#- Download Original (Exportieren des Originals): Exportieren des originalen Files
#- Manage permissions: Verwalten der Berechtigungen auf einer Ressource
#- Ownership: Person, die eine Ressource importiert/erstellt hat, hat defaultmässig die Ownership und alle obigen Berechtigungen.
#- Nennt man eine Person oder eine Gruppe bei den Berechtigungen, wählt für diese aber keine Berechtigungen aus, so bedeutet dies, dass den genannten explizit die Berechtigungen entzogen sind.


  @transactional_dirty
  Scenario: No permissions
    Given I am signed-in as "Normin"
    And A resource with no permissions whatsoever
    And I visit the path of the resource
    Then I am redirected to the main page

  @transactional_dirty
  Scenario: View permission
    Given I am signed-in as "Normin"
    And A resource with no permissions whatsoever
    When There are "view" user-permissions added for me to the resources
    And I visit the path of the resource
    Then I see page for the resource


  @jsbrowser @dirty
  Scenario: Not Manage permission
    Given I am signed-in as "Normin"
    And A resource with no permissions whatsoever
    When There are "view" user-permissions added for me to the resources
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can not edit the permissions

  @jsbrowser @dirty
  Scenario: Manage permission
    Given I am signed-in as "Normin"
    And A resource with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resources
    And There are "manage" user-permissions added for me to the resources
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can edit the permissions





