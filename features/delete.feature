Feature: Delete

  As a MAdeK user 
  I want to be able to delete resources that I am responsible for
  So that I can remove things I dont want anymore

  @jsbrowser 
  Scenario: Access delete action for media resources on my dashboard
    Given I am signed-in as "Normin"
    And I am on the dashboard
    Then I can see the delete action for media resources where I am responsible for
    And I cannot see the delete action for media resources where I am not responsible for

  @jsbrowser 
  Scenario: Access delete action for media resources on a media resources list
   Given I am signed-in as "Normin"
    When I see a list of resources 
    Then I can see the delete action for media resources where I am responsible for
    And I cannot see the delete action for media resources where I am not responsible for

  @jsbrowser 
  Scenario: Access delete action for media entry on media entry page
   Given I am signed-in as "Normin"
    When I open a media entry where I have all permissions but I am not the responsible user
    Then I cannot see the delete action for this resource
    When I open a media entry where I am the responsible user
    Then I can see the delete action for this resource

  @jsbrowser 
  Scenario: Access delete action for media set on media set page
   Given I am signed-in as "Normin"
   When I open a media set where I have all permissions but I am not the responsible user
   Then I cannot see the delete action for this resource
   When I open a media set where I am the responsible user
   Then I can see the delete action for this resource

  @chrome 
  Scenario: Importing and deleting an image
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "images/berlin_wall_01.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter..." 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    And I remember the last imported media_entry with media_file and the actual file
    And I visit the media_entry

    Then The media_resource does exist
    And The media_file does exist
    And The actual_file does exist 

    And I click on the link "Weitere Aktionen"
    And I click on "Löschen"
    And I click on "Löschen"

    Then The media_entry doesn't exist anymore
    And The media_file doesn't exist anymore
    And The actual_file doesn't exist anymore
