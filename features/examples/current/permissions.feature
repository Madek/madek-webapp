
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
  As a user
  I want to have different permissions on resources
  So that I can decide who has what kind of access to my data

  Background: Load the example data and personas
	Given I have set up the world
    And personas are loaded

  @javascript
  Scenario: View permission
    Given a resource
      And I am "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |view             |true |
     Then "Normin" can view the resource

  @javascript
  Scenario: Edit permission
    Given a resource
      And I am "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |edit             |true |
     Then "Normin" can edit the resource

  @javascript
  Scenario: Download original permission
    Given a resource
      And I am "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |download         |true |
     Then "Normin" can download the resource
     
  @javascript
  Scenario: Manage permission
    Given a resource
      And I am "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |manage           |true |
     Then "Normin" can manage the resource

  @javascript
  Scenario: Owner permission
    Given a resource
      And I am "Normin"
     Then "Normin" is the owner of the resource
  
  @javascript
  Scenario: Permission which allows a user to add MediaResources to a MediaSet  
    Given a set named "Editable Set"
      And I am "Normin"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |edit             |true |
      And a set named "Viewable Set"
      And the resource has the following permissions:
      |user              |permission       |value|
      |Normin            |view             |true |
     When "Normin" adds the set "Viewable Set" to the set "Editable Set"
     Then "Viewable Set" is in "Editable Set"

  @javascript
  Scenario: Permissions through groups
  # Petra and Normin are members of the ZHdK Group.
  # Normin's Diplomarbeit (Set) is viewable by Petra, because Normin granted view permissions
  # for the ZHdK Group and Petra is member of that group. 
    Given I am "Petra"
      And I can view "Diplomarbeit 2012" by "Normin"

  @javascript
  Scenario: Users with explicit user permissions are explicitly excluded even when they would have group permissions
    # Petra and Normin are members of the ZHdK Group.
    # Normin's MediaSet "Meine Highlights 2012" is viewable by the ZHdK Group,
    # but he excluded Petra with explicit UserPermissions,
    # because he discovered that she is copy pasting his images from there to share them with others
    Given I am "Petra"
      And I can not view "Meine Highlights 2012" by "Normin"

  # https://www.pivotaltracker.com/story/show/25238301
  @javascript
  Scenario: Permission presets
    Given I am "Normin"
     When I open one of my resources
      And I open the permission lightbox
     Then I can choose from a set of labeled permissions presets instead of grant permissions explicitly    
  
  # https://www.pivotaltracker.com/story/show/23723319
  Scenario: Limiting what other users' permissions I can see
    Given a resource owned by "Susanne Schumacher"
      And the resource has the following permissions:
      |user |permission |value|
      |Susanne Schumacher|view |yes |
      |Susanne Schumacher|download original|yes |
      |Susanne Schumacher|edit |yes |
      |Susanne Schumacher|manage |yes |
      |Ramon Cahenzli|view|yes|
      |Franco Sellitto|edit|yes|
      |Franco Sellitto|download original|yes|
      |Sebastian Pape|edit|yes|
      |Sebastian Pape|download original|yes|
    When the resource is viewed by "Susanne Schumacher"
    Then he or she sees the following permissions:
      |user |permission |value|
      |Susanne Schumacher|view |yes |
      |Susanne Schumacher|download original|yes |
      |Susanne Schumacher|edit |yes |
      |Susanne Schumacher|manage |yes |
      |Ramon Cahenzli|view|yes|
      |Franco Sellitto|edit|yes|
      |Franco Sellitto|download original|yes|
      |Sebastian Pape|edit|yes|
      |Sebastian Pape|download original|yes|
    When the resource is viewed by "Franco Sellitto"
    Then he or she sees the following permissions:
      |user |permission |value|
      |Susanne Schumacher|view |yes |
      |Ramon Cahenzli|view|yes|
    When the resource is viewed by "Sebastian Pape"
    Then he or she sees the following permissions:
      |user |permission |value|      
      |Susanne Schumacher|edit |yes |
      |Franco Sellitto|edit|yes|      
      |Sebastian Pape|edit|yes|
    When the resource is viewed by "Ramon Cahenzli"
    Then he or she sees the following permissions:
      |user |permission |value|
      |Susanne Schumacher|view |yes |      
      |Ramon Cahenzli|view|yes|
    
  # https://www.pivotaltracker.com/story/show/23723319
  Scenario: Viewing the members of a group
    Given a group "Some People" with the members:
    |member|
    |Person A|
    |Person B|
    When I edit the permissions of a media entry
     And I give view permission to the group "Some People"
    Then I can choose to view a list of members of this group
     And the list contains:
    |members|
    |Person A|
    |Person B|