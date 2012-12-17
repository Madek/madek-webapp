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


Feature: Responsibility

  As a user
  I want to feel that I own my files
  So that I have a mental connection to them and am not confused by other people's files, or other files I have access to

  Background: Load the example data and personas
   Given I am "Normin"

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Only one owner per resource
     When I change the owner to "Adam"
     Then I am no longer the owner
      And the resource is owned by "Adam"
 
  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Groups cannot be responsible
     When I open the set called "Abgabe zum Kurs Product Design"
      And I want to change the responsibility
     Then I can choose a user as responsible
      And I can not choose any groups as responsible

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Interface for changing responsibility
    Given a resource I am responsible for
     When I vist that resource's page
     Then I can use some interface to change the responsible person of that resource to "Adam"

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: Only responsible users can change responsibility
    When I open a media resource someone else is responsible for
    Then I cannot change the responsibility 

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: responsible users have all permissions on a resource
    When I open one of my resources
    When I open the permission lightbox
    Then I should have all permissions

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: responsible users can assign permissions to other people
    Given a resource "Normin" is responsible for
     When "Normin" changes the resource's permissions for "Petra" as follows:
     |permission       |value|
     |view             |true  |
     |download         |false |
     |edit             |true  |
     |manage           |true  |
     Then the resource has the following permissions for "Petra":
     |permission       |value|
     |view             |true  |
     |download         |false |
     |edit             |true  |
     |manage           |true  |

  # https://www.pivotaltracker.com/story/show/23669443
  @javascript
  Scenario: A resource's creator is automatically its responsible user
    When I create a resource
    Then I am the user responsible of that resource

  # https://www.pivotaltracker.com/story/show/23670991
  @javascript
  Scenario: Visible representation of responsibility
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
    Then I see a list of content I am responsible for
     And I see a list of content that can be managed by me
     And I see a list of other people's content that is visible to me

  # https://www.pivotaltracker.com/story/show/24839993
  @javascript
  Scenario: Seeing the user responsible to content
    Given I am "Petra"
     When I open a media entry someone else is responsible for
     Then I see who is the responsible user
     When I open a media set someone else is responsible for
     Then I see who is the responsible user

  @glossary
  Scenario: responsibility
  Given I am a user that has responsibility for a resource
   Then I am figured as responsible user
