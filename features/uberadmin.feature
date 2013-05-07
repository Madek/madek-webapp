Feature: Acting as an Uberadmin

  @jsbrowser
  Scenario: Becoming an Uberadmin, viewing things, and leaving Ueberadmin-Mode
    Given I am signed-in as "Adam"
    And I visit "/media_resources?filterpanel=true"
    And I remember the number of resources
    And I click on "Adam Admin"
    And I click on "Werde Überadmin" 
    Then I can see more resources than before
    And I can see all resources
    When I click on "Adam Admin"
    And I click on "Verlasse Überadmin-Modus"
    Then I see exactly the same number of resources as before

  @jsbrowser
  Scenario: Viewing and editing a private entry as Überadmin
    Given I am signed-in as "Adam"
    And the resource with the id "65" has doesn't belong to me and has no other permissions
    And the resource with the id "65" has no public view permission
    And I visit "/media_entries/65"
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."
    When I click on "Adam Admin"
    And I click on "Werde Überadmin" 
    And I visit "/media_entries/65"
    Then I am on the "/media_entries/65" page
    When I click on "Weitere Aktionen"
    And I click on "Metadaten editieren" 
    Then I am on the "/media_resources/65/edit" page
    When I set the input in the fieldset with "title" as meta-key to "XYZ Titel"
    And I submit
    Then I am on the "/media_entries/65" page
    And I can see "XYZ Titel"
    And I am the last editor of the media entry with the id "65"
    When I click on "Adam Admin"
    And I click on "Verlasse Überadmin-Modus"
    Then I am on the "/my" page
    And I can see "Sie haben nicht die notwendige Zugriffsberechtigung."


