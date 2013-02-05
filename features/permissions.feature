Feature: Permissions
  As an user I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

  As an owner of a Resource, I want to assign various permissions
  to users and groups.

  @chrome 
  Scenario: Assigning user permissions
    Given I am signed-in as "Normin"
    And My first media_entry has no permissions whatsoever.
    And I visit the path of my first media entry
    And I open the edit-permissions dialog
    When I click on the link "Person hinzufügen" 
    And I set the input with the name "user" to "Paula, Petra"
    And I click on "Paula, Petra" inside the autocomplete list
    Then the "view" permission for "Paula, Petra" is checked
    When I click on the "download" permission for "Paula, Petra"
    Then the "download" permission for "Paula, Petra" is checked
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then User "petra" has "view" user-permissions for my first media_entry
    Then User "petra" has "download" user-permissions for my first media_entry
    Then User "petra" has not "edit" user-permissions for my first media_entry

  @chrome 
  Scenario: Assigning group permissions
    Given I am signed-in as "Normin"
    And My first media_entry has no permissions whatsoever.
    And I visit the path of my first media entry
    And I open the edit-permissions dialog
    When I click on the link "Gruppe hinzufügen" 
    And I set the input with the name "group" to "Zett"
    And I click on "Zett" inside the autocomplete list
    Then the "view" permission for "Zett" is checked
    When I click on the "download" permission for "Zett"
    Then the "download" permission for "Zett" is checked
    And I click on the button "Speichern" 
    And I wait for the dialog to disappear
    Then Group "Zett" has "view" group-permissions for my first media_entry
    Then Group "Zett" has "download" group-permissions for my first media_entry
    Then Group "Zett" has not "edit" group-permissions for my first media_entry


#Berechtigungen:
#Es gibt folgende Berechtigungen auf Ressourcen im Medienarchiv (In Klammer die deutschen Bezeichnungen des Interfaces):
#- View (Sehen): sehen einer Ressource
#- Edit (Editieren): editieren von Metadaten einer Ressource, hinzufügen und wegnehmen von Ressourcen zu einem Set
#- Download Original (Exportieren des Originals): Exportieren des originalen Files
#- Manage permissions: Verwalten der Berechtigungen auf einer Ressource
#- Ownership: Person, die eine Ressource importiert/erstellt hat, hat defaultmässig die Ownership und alle obigen Berechtigungen.
#- Nennt man eine Person oder eine Gruppe bei den Berechtigungen, wählt für diese aber keine Berechtigungen aus, so bedeutet dies, dass den genannten explizit die Berechtigungen entzogen sind.

# the notion of "ownership" has changed; a resource has an fkey pointing to a
# user, this is what used to be the 'owner' and is now called the 'responsible
# person' in the ui; the term 'owner' is still used in the specifications below

  Scenario: No permissions
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    And I visit the path of the resource
    Then I am redirected to the main page

  Scenario: View user-permission lets me view the resource
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And I visit the path of the resource
    Then I see page for the resource

  Scenario: View group-permission lets me view the resource
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" group-permissions added for me to the resource
    And I visit the path of the resource
    Then I see page for the resource

  @jsbrowser 
  Scenario: Not manage user-permission won't let me edit permissions
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can not edit the permissions

  @jsbrowser 
  Scenario: Manage permission
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And There are "manage" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I can edit the permissions

  @jsbrowser
  Scenario: No edit user-permission won't let mit edit metadata
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When I visit the edit path of the resource
    Then I see an error alert

  # test override only once
  @jsbrowser 
  Scenario: No edit user-permission overrides edit user-permission
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When There are "view" group-permissions added for me to the resource
    When There are "edit" group-permissions added for me to the resource
    When I visit the edit path of the resource
    Then I see an error alert

  @jsbrowser
  Scenario: Edit user-permission will let me edit metadata
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When There are "edit" user-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Weitere Aktionen"
    And I click on the link "Metadaten editieren"
    And I am on the edit page of the resource
    When I click on the submit button
    Then I am on the page of the resource
    And I see a confirmation alert

  @jsbrowser
  Scenario: Edit group-permission will let me edit metadata
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" group-permissions added for me to the resource
    When There are "edit" group-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Weitere Aktionen"
    And I click on the link "Metadaten editieren"
    And I am on the edit page of the resource
    When I click on the submit button
    Then I am on the page of the resource
    And I see a confirmation alert

  @jsbrowser
  Scenario: Not the owner / responsible user of a resource 
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And There are "manage" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I am not the responsible person for that resource

  @jsbrowser @clean
  Scenario: Owner / responsible user of a resource
    Given I am signed-in as "Normin"
    And A resource owned by me
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I am the responsible person for that resource

  @jsbrowser
  Scenario: No Download permission will not let me download the resource
    Given I am signed-in as "Normin"
    And A media_entry with file, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Exportieren" 
    And I click on the link "Datei ohne Metadaten" inside of the dialog 
    Then There is no link with class "original" in the list with class "download"
    
  @jsbrowser
  Scenario: Download permission will let me download the resource
    Given I am signed-in as "Normin"
    And A media_entry with file, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    When There are "download" user-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Exportieren" 
    And I click on the link "Datei ohne Metadaten" inside of the dialog 
    Then There is a link with class "original" in the list with class "download"

  @jsbrowser
  Scenario: Download permission will let me download the resource
    Given I am signed-in as "Normin"
    And A media_entry with file, not owned by normin, and with no permissions whatsoever 
    When There are "view" group-permissions added for me to the resource
    When There are "download" group-permissions added for me to the resource
    And I visit the path of the resource
    And I click on the link "Exportieren" 
    And I click on the link "Datei ohne Metadaten" inside of the dialog 
    Then There is a link with class "original" in the list with class "download"
    
  @jsbrowser
  Scenario: Permissions for adding a resource to a set
    Given I am signed-in as "Normin"
    And A media_entry with file, not owned by normin, and with no permissions whatsoever 
    And There are "view" user-permissions added for me to the resource
    And There are "edit" user-permissions added for me to the resource
    Given A set, not owned by normin, and with no permissions whatsoever 
    And The set has no children
    And There are "view" user-permissions added for me to the set
    And There are "edit" user-permissions added for me to the set
    And I visit the path of the resource
    And I click on the link "Weitere Aktionen"
    And I click on the link "Zu Set hinzufügen"
    And I add the resource to the given set 
    Then the resource is in the children of the given set

  @jsbrowser @clean
  Scenario: Permission presets
    Given I am signed-in as "Normin"
      And A resource owned by me and defined userpermissions for "Petra"
      And I visit the path of the resource
      And I click on the link "Weitere Aktionen"
      And I click on the link "Zugriffsberechtigungen"
     Then I can choose from a set of labeled permissions presets instead of grant permissions explicitly    

  @jsbrowser @dirty 
  Scenario: Limiting what other users' permissions I can see
    Given I am signed-in as "Normin"
    Given A resource owned by me with no other permissions
      And The resource has the following user-permissions:
      | user      | permission | value |
      | Normin    | view       | true  |
      | Normin    | download   | true  |
      | Normin    | edit       | true  |
      | Normin    | manage     | true  |
      | Petra     | view       | true  |
      | Beat      | view       | true  |
      | Beat      | edit       | true  |
      | Beat      | download   | true  |
      | Liselotte | view       | true  |
      | Liselotte | edit       | true  |
      | Liselotte | download   | true  |
    And I logout.

    Given I am signed-in as "Normin"
    And visit the permissions dialog of the resource
    Then I see the following permissions:
      | user      | permission |
      | Normin    | view       |
      | Normin    | download   |
      | Normin    | edit       |
      | Normin    | manage     |
      | Petra     | view       |
      | Beat      | edit       |
      | Beat      | download   |
      | Liselotte | edit       |
      | Liselotte | download   |
    And I close the modal dialog.
    And I logout.

    Given I am signed-in as "Beat"
    And I visit the permissions dialog of the resource
    Then I see the following permissions:
      | user   | permission |
      | Normin | view       |
      | Petra  | view       |
    And I close the modal dialog.
    And I logout.

    Given I am signed-in as "Liselotte"
    And I visit the permissions dialog of the resource
    Then I see the following permissions:
      | user      | permission |
      | Normin    | edit       |
      | Beat      | edit       |
      | Liselotte | edit       |
    And I close the modal dialog.
    And I logout.

    Given I am signed-in as "Petra"
    And I visit the permissions dialog of the resource
    Then I see the following permissions:
      | user   | permission |
      | Normin | view       |
      | Petra  | view       |
    And I close the modal dialog.
    And I logout.

  @chrome @dirty
  Scenario: Display the complete LDAP name on the selection dropdown
    Given I am signed-in as "Normin"
    And I have set up some departments with ldap references
    And A resource owned by me with no other permissions
    When I visit the permissions dialog of the resource
    Then I can select "Vertiefung Industrial Design (DDE_FDE_VID.dozierende)" to grant group permissions
    When I click on the submit button
    Then I am on the page of the resource
    And I see a confirmation alert

