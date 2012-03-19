# See also the sketch at:
# https://www.pivotaltracker.com/story/show/23669443
#
#Konzept Ownership:
#- Es gibt für eine Ressource im Medienarchiv nur einen Owner ("Only one owner per resource")
#- Dieser Owner ist eine Person, keine Gruppe von Personen ("Groups cannot be owners")
#- Die Ownership kann im Interface bei den Berechtigungen auf eine andere Person übertragen werden. ("Interface for changing owners")
#- Nur der Owner kann die Ownership auf eine andere Person übertragen. ("Only owners can change ownership")
#- Ein Owner einer Ressource kann diese sehen, die Metadaten editieren, diese in voller Auflösung exportieren und die Berechtigungen der Ressource verwalten. ("Owners have all permissions on a resource")
#- Ein Owner kann anderen Personen, anderen Gruppen und der Öffentlichkeit die Rechte, eine Ressource zu sehen, zu editieren, volle Auflösungen exportieren und deren Rechte zu managene zuweisen. ("Owners can assign permissions to other people") Frage Einschränkung: Dürfen Berechtigungen auch von Gruppen verwaltet werden oder nur von Personen?
#- Im Admin-Interface kann die Ownership von Ressourcen übertragen werden ("The admin interface allows assigning permissions")


Feature: Ownership

  As a user
  I want to feel that I own my files
  So that I have a mental connection to them and am not confused by other people's files, or other files I have access to

  Background: Load the example data and personas
   Given I have set up the world
     And personas are loaded
     And I am "Normin"

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Only one owner per resource
     When I change the owner to "Adam"
     Then I am no longer the owner
      And the resource is owned by "Adam"
 
  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Groups cannot be owners
     When I open the set called "Abgabe zum Kurs Product Design"
      And I want to change the owner
     Then I can choose a user as owner
      And I can not choose any groups as owner

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Interface for changing owners
    Given a resource owned by me
     When I vist that resource's page
     Then I can use some interface to change the resource's owner to "Adam"

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Only owners can change ownership
    When I open a media resource owned by someone else
    Then I cannot change the owner 

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Owners have all permissions on a resource
    When I open one of my resources
    When I open the permission lightbox
    Then I should have all permissions

  # https://www.pivotaltracker.com/story/show/23669443
  Scenario: Owners can assign permissions to other people
    Given a resource owned by "Normin"
     When "Normin" changes the resource's permissions as follows:
     |user          |permission       |value|
     |Petra|view             |yes  |
     |Petra|download original|no   |
     |Petra|edit             |yes  |
     |Petra|manage           |yes  |
     Then the resource has the following permissions:
     |Petra|view             |yes  |
     |Petra|download original|no   |
     |Petra|edit             |yes  |
     |Petra|manage           |yes  |

  # https://www.pivotaltracker.com/story/show/23669443
  Scenario: The admin interface allows assigning permissions
    Given a resource owned by "Susanne Schumacher"
      And a resource owned by "Ramon Cahenzli"
     When I go to the admin interface
      And I assign the resources to "Susanne Schumacher"
     Then both resources are owned by "Susanne Schumacher"

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: A resource's creator is automatically its owner
    When I create a resource
    Then I am the owner of that resource

  # https://www.pivotaltracker.com/story/show/23669443
  Scenario: Ownership on snapshots
   Given I am member of the group "Expert"
    When I create a snapshot of a media entry owned by "Susanne Schumacher"
    Then I am the owner of the snapshot
     And "Susanne Schumacher" is still the original media entry's owner

  # https://www.pivotaltracker.com/story/show/23670991
  @javascript
  Scenario: Visible representation of ownership
  Given I am "Normin"
   When I see a list of resources
   Then I can see if a resource is only visible for me
    And I can see if a resource is visible for multiple other users
    And I can see if a resource is visible for the public

  # https://www.pivotaltracker.com/story/show/24869787
  @javascript
  Scenario: My content, content I manage, other people's content
	Given I am "Normin"
    When I am on the dashboard
    Then I see a list of content owned by me
     And I see a list of content that can be managed by me
     And I see a list of other people's content that is visible to me

  # https://www.pivotaltracker.com/story/show/24839993
  @javascript
  Scenario: Seeing the owner of content
    Given I am "Normin"
     When I open a media entry
     Then I see who is the owner
     When I open a media set
     Then I see who is the owner

  @glossary
  Scenario: Owner
  Given I am a user in the system
   When I have ownership of a resource
   Then I am the owner of that resource

