Feature: Permissions
  As an user I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

  As an owner of a Resource, I want to assign various permissions
  to users and groups.

  @jsbrowser
  Scenario: Not the owner / responsible user of a resource 
    Given I am signed-in as "Normin"
    And A resource, not owned by normin, and with no permissions whatsoever 
    When There are "view" user-permissions added for me to the resource
    And There are "manage" user-permissions added for me to the resource
    And I visit the path of the resource
    And I open the edit-permissions dialog
    Then I am not the responsible person for that resource

  @jsbrowser
  Scenario: Owner / responsible user of a resource
    Given I am signed-in as "Normin"
    And A resource owned by me with view permission explicitly set for me
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

  @jsbrowser 
  Scenario: Permission presets
    Given I am signed-in as "Normin"
      And A resource owned by me and defined userpermissions for "Petra"
      And I visit the path of the resource
      And I click on the link "Weitere Aktionen"
      And I click on the link "Berechtigungen"
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
    And I visit the permissions dialog of the resource
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


