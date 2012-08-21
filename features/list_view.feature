Feature: List view

  As a MAdeK user
  I want to see resources in a list view
  so that I can see a lot of metadata at one glance
  instead of having to click on every resource

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Normin"

  @javascript
  Scenario: What I see when I am on a list view
    Given I see a list of resources
    When I switch to the list view
    Then each resource is represented as one row of data
    And for each resource I see meta data from the "core" context
    And for each resource I see a thumbnail image if it is available
    And for each resource I see an icon if no thumbnail is available
  
  @javascript
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
  
  # not yet commited
  # Scenario: Accessing the export function in list view
    # Given this scenario is pending
    # When I see a resource in a list view
    # Then the following actions are available for this resource:
    # | action      |
    # | Exportieren | 
    # When I choose "Exportieren"
    # Then I see a dialog allowing me to export the resource
  
  @javascript
  Scenario: The title in list view
    When I see a resource in a list view
    Then the resource's title is highlighted
    When I click the title
    Then I'm redirected to the media resource's detail page 
  
  @javascript
  Scenario: Height of a row in list view
    When I see a list of resources
    Then one resource can be taller caused by it's visible meta data
  
  @javascript
  Scenario: Thumbnails in list view
    When I see a resource in a list view
    Then the resource shows an icon representing its permissions

  @javascript
  Scenario: Behavior when clicking a thumbnail in list view
    When I see a resource in a list view
    And I click the thumbnail of that resource
    Then I'm redirected to the media resource's detail page

  @javascript
  Scenario: Contexts visible in list view
    When I see a resource in a list view
    Then I see the meta data for context "Core"
    And I see the meta data for context "Institution" after some loading
    And I see the meta data for context "Nutzung" after some loading

  @javascript
  Scenario: Information about parent and children
   When I see a list of sets in list view
    And I see the "children" meta key of a set
   Then I see the number and type of children
    And the type is shown through an icon
   When I see the "parents" meta key of a set
   Then I see the number and type of parents
    And the type is shown through an icon