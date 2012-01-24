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

  Scenario: Only one owner per resource
    Given a resource owned by me
     When I change the owner to "Susanne Schumacher" # TODO: Use personas here
     Then I am no longer the owner
      And the resource is owned by "Susanne Schumacher"

  Scenario: Groups cannot be owners
    Given a resource owned by me
     When I want to change the owner
     Then I can choose only users
      And I can not choose any groups

  Scenario: Interface for changing owners
    Given a resource owned by me
     When I go to that resource's page
     Then I can use some interface to change the resource's owner to "Susanne Schumacher"

  Scenario: Only owners can change ownership
    Given a resource owned by "Susanne Schumacher"
     When I want to change the owner
     Then I get an error message
      And the resource is owned by "Susanne Schumacher"

  Scenario: Owners have all permissions on a resource
    Given a resource owned by "Susanne Schumacher"
     When I look at the permissions on that resource
     Then the resource has the following permissions:
     |user              |permission       |value|
     |Susanne Schumacher|view             |yes  |
     |Susanne Schumacher|download original|yes  |
     |Susanne Schumacher|edit             |yes  |
     |Susanne Schumacher|manage           |yes  |

  Scenario: Owners can assign permissions to other people
    Given a resource owned by "Susanne Schumacher"
     When "Susanne Schumacher" changes the resource's permissions as follows:
     |user          |permission       |value|
     |Ramon Cahenzli|view             |yes  |
     |Ramon Cahenzli|download original|no   |
     |Ramon Cahenzli|edit             |yes  |
     |Ramon Cahenzli|manage           |yes  |
     Then the resource has the following permissions:
     |Ramon Cahenzli|view             |yes  |
     |Ramon Cahenzli|download original|no   |
     |Ramon Cahenzli|edit             |yes  |
     |Ramon Cahenzli|manage           |yes  |

  Scenario: The admin interface allows assigning permissions
    Given a resource owned by "Susanne Schumacher"
      And a resource owned by "Ramon Cahenzli"
     When I go to the admin interface
      And I assign the resources to "Susanne Schumacher"
     Then both resources are owned by "Susanne Schumacher"

  Scenario: A resource's creator is automatically its owner
    When I create a resource
    Then I am the owner of that resource

  Scenario: Ownership on snapshots
   Given I am member of the group "Expert"
    When I create a snapshot of a media entry owned by "Susanne Schumacher"
    Then I am the owner of the snapshot
     And "Susanne Schumacher" is still the original media entry's owner

