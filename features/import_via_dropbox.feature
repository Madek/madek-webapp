Feature: Import via Dropbox

  As a MAdeK user
  I want a upload big files what is not possible through the browser
  So that I can import big files

  Background:
    Given I am signed-in as "Normin"

  @jsbrowser
  Scenario: Create my dropbox
    When I go to the import page
     And I open the dropbox informations dialog
     And I create a dropbox
    Then the dropbox was created for me
     And I can see instructions for an FTP import

  @jsbrowser @clean
  Scenario: Importing large files
    When I try to import a file with a file size greater than 1.4 GB
    Then I see an error alert
     And I can see instructions for an FTP import

  @chrome
  Scenario: Importing via a dropbox
    Given the current user has a dropbox
     When I upload some files to my dropbox
     Then those files are getting imported during the upload