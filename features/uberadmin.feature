Feature: Acting as an Uberadmin

  @jsbrowser
  Scenario: Becoming an Uberadmin, viewing things, and leaving Ueberadmin-Mode
    Given I am signed-in as "Adam"
    And I visit "/media_resources?filterpanel=true"
    And I remember the number of resources
    And I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln" 
    Then I can see more resources than before
    And I can see all resources
    When I click on "Adam Admin"
    And I click on "Admin-Modus verlassen"
    Then I see exactly the same number of resources as before

  @jsbrowser
  Scenario: Viewing and editing a private entry as Überadmin
    Given I am signed-in as "Adam"
    And the resource with the id "a9b857f0-0653-4304-b156-86a86985c6dd" has doesn't belong to me and has no other permissions
    And the resource with the id "a9b857f0-0653-4304-b156-86a86985c6dd" has no public view permission
    And I visit "/media_entries/a9b857f0-0653-4304-b156-86a86985c6dd"
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."
    When I click on "Adam Admin"
    And I click on "In Admin-Modus wechseln" 
    And I visit "/media_entries/a9b857f0-0653-4304-b156-86a86985c6dd"
    Then I am on the "/media_entries/a9b857f0-0653-4304-b156-86a86985c6dd" page
    When I click on "Weitere Aktionen"
    And I click on "Metadaten editieren" 
    Then I am on the "/media_resources/a9b857f0-0653-4304-b156-86a86985c6dd/edit" page
    When I set the input in the fieldset with "title" as meta-key to "XYZ Titel"
    And I submit
    Then I am on the "/media_entries/a9b857f0-0653-4304-b156-86a86985c6dd" page
    And I can see "XYZ Titel"
    And I am the last editor of the media entry with the id "a9b857f0-0653-4304-b156-86a86985c6dd"
    When I click on "Adam Admin"
    And I click on "Admin-Modus verlassen"
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."


