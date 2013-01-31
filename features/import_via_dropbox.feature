Feature: Import via Dropbox

  As a MAdeK user
  I want a upload big files what is not possible through the browser
  So that I can import big files

  @wip
  Background: Load the example data and personas
    Given I am "Normin"
      And all users have dropboxes

  @wip
  Scenario: Importing large files
    When I import a file with a file size greater than 1.4 GB
    Then the system gives me a warning telling me it's impossible to import so much through the browser
     And the warning includes instructions for an FTP import

  @wip
  Scenario: Importing via a dropbox
    When I have imported some files to my dropbox
     And I start a new import process
    Then I can choose files from my dropbox instead of importing them through the browser

  @wip
  Scenario: Recursively searching for importable files in my dropbox
    When I have imported a directory containing files to my dropbox
     And I start a new import process
    Then I can choose files from my dropbox instead of importing them through the browser