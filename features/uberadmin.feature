Feature: Acting as an Uberadmin

  Background: 
    Given I am signed-in as "Adam"

  @jsbrowser
  Scenario: Becoming an Uberadmin, viewing things, and leaving Uberadmin-Mode
    When I visit "/media_resources?filterpanel=true"
    And I remember the number of resources
    And I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln" 
    Then I can see more resources than before
    And I can see all resources
    When I click on "Adam Admin"
    And I click on "Admin-Modus verlassen"
    Then I see exactly the same number of resources as before

  @firefox
  Scenario: Viewing and editing a private entry as Überadmin
    When I remember a media_entry that doesn't belong to me, has no public, nor other permissions
    And I visit the media_entry
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."
    When I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln" 
    And I visit the media_entry
    Then I am on the page of the resource
    And I click on the button with title "Metadaten editieren" 
    Then I am on the edit page of the resource
    When I set the input in the fieldset with "title" as meta-key to "XYZ Titel"
    And I submit
    Then I am on the page of the resource
    And I can see "XYZ Titel"
    And I am the last editor of the remembered resource
    When I click on "Adam Admin"
    And I click on "Admin-Modus verlassen"
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."

  @jsbrowser
  Scenario: Deleting a private media entry in admin mode
    When I remember a media_entry that doesn't belong to me, has no public, nor other permissions
    And I visit the media_entry
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."
    When I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln"
    And I visit the media_entry
    Then I am on the page of the resource
    When I click on the button with title "Löschen" 
    And I confirm the modal
    Then The media_entry doesn't exist anymore
