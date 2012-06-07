Feature: List view

  As a MAdeK user
  I want to see resources in a list view
  so that I can see a lot of metadata at one glance
  instead of having to click on every resource

  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded
      And I am "Normin"

  Scenario: What I see when I am on a list view
    Given I see a list of resources
    When I switch to the list view
    Then each resource is represented as one row of data
    And for each resource I see meta data from the "core" context
    And for each resource I see a thumbnail image if it is available
    And for each resource I see an icon if no thumbnail is available

  Scenario: Actions available for a resource
    When I see a resource in a list view
    Then the following actions are available for this resource:
    | action                                       |
    | Editieren                                    |
    | Als Favorit merken                           |
    | Zugriffsberechtigungen lesen/bearbeiten      |
    | Zu Set hinzufügen/entfernen                  |
    | Erkunden nach vergleichbaren Medieneinträgen |
    | Löschen                                      |
    | Zur Auswahl hinzufügen/entfernen             |

  Scenario: Accessing the export function in list view
    Given this scenario is pending
    When I see a resource in a list view
    Then the following actions are available for this resource:
    | action      |
    | Exportieren | 
    When I choose "Exportieren"
    Then I see a dialog allowing me to export the resource

  Scenario: Styling of the title in list view
    When I see a resource in a list view
    Then the resource's title is highlighted
  
  Scenario: Height of a row in list view
    Given I see a list of resources
    When I switch to the list view
    And one resource has more metadata than another
    Then the row containing the resource with more metadata is taller than the other

  Scenario: Thumbnails in list view
    When I see a resource in a list view
    Then the resource shows an icon representing its permissions

  Scenario: Styling of thumbnails in list view
    When I see a resource in a list view
    And the resource is a video file
    Then the thumbnail or icon is surrounded by a film strip

  Scenario: Behavior when clicking a thumbnail in list view
    When I see a resource in a list view
    And I click the thumbnail of that resource
    Then I am on the resource's view page

  Scenario: Contexts visible in list view
    When I see a resource in list view
    Then I see the context "Core"
    And I see the context "Institution" after some loading
    And I see the context "Nutzung" after some loading

  @javascript
  Scenario: Information about parent and children
    When I see a list of sets in list view
     And I see the "children" meta key of a set
     And I see the "parents" meta key of a set
    Then I see the number and type of children
     And there is one number for media entries
     And there is one number for sets
    And one of the resources has parents
    Then I see the number and type of parents
     And there is one number for sets
     
  @javascript
  Scenario: Information about parent and children with icons
   When I see a list of sets in list view
    And I see the "children" meta key of a set
   Then I see the number and type of children
    And the type is shown through an icon
    And there is one number for media entries
    And there is one number for sets
   And one of the resources has parents
   Then I see the number and type of parents
    And the type is shown through an icon
    And there is one number for sets
