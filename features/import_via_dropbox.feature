Feature: Import via Dropbox

  As a MAdeK user
  I want a upload big files what is not possible through the browser
  So that I can import big files

  @jsbrowser
  Scenario: Create my dropbox
    Given I am signed-in as "Normin"
    When I go to the import page
     And I open the dropbox informations dialog
     And I create a dropbox
    Then the dropbox was created for me
     And I can see instructions for an FTP import

  @jsbrowser @clean
  Scenario: Importing large files
    Given I am signed-in as "Normin"
    When I try to import a file with a file size greater than 1.4 GB
    Then I see an error alert
     And I can see instructions for an FTP import

  @chrome
  Scenario: Importing via a dropbox
    Given I am signed-in as "Normin"
    Given the current user has a dropbox
     When I upload some files to my dropbox
     Then those files are getting imported during the upload

  @chrome
  Scenario: Deleting files during the import via a dropbox
    Given I am signed-in as "Normin"
    And I am going to import images
    And There is no media-entry with a filename matching "berlin"
    And There is no incomplete media-entry with a filename matching "berlin"

    When I upload the file "berlin_wall_01.jpg" via dropbox
    And I upload the file "berlin_wall_02.jpg" via dropbox

    And I go to the import page
    And I delete the import "berlin_wall_01.jpg"
    And I confirm the browser dialog
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 01" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "1" new media_entries
    And There is exactly one media-entry with a filename matching "berlin"
    And There is no media-entry incomplete with a filename matching "berlin"









