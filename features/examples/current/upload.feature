Feature: Upload
  As a user
  I want to upload files to the system
  So that I can share my files with everyone


  Scenario: Setting permissions during upload
    When I upload a file
    Then the file is attached to a media entry
     And I can set the permissions for the media entry during the upload process

  Scenario: Filling in core metadata during upload
    When I upload a file
    Then the file is attached to a media entry
     And I fill in the metadata form as follows:
     |label                              |value|
     |Titel                              |Test image for uploading|
     |Autor/in                           |Hans Franz|
     |Datierung                          |2011-08-08|
     |Schlagworte zu Inhalt und Motiv    |some|
     |Schlagworte zu Inhalt und Motiv    |test|
     |Copyright                          |Tester|

  Scenario: Adding to a set during upload
    When I upload a file
    Then the file is attached to a media entry
     And I add the media entry to a set called "Test Set"

  Scenario: Uploading large files
    When I upload files totalling more than 1.5 GB
    Then the system gives me a warning telling me it's impossible to upload so much through the browser
     And the warning includes instructions for an FTP upload

  Scenario: Uploading via a dropbox
    When I have uploaded some files to my dropbox
     And I start a new upload process
    Then I can choose files from my dropbox instead of uploading them through the browser

  Scenario: Recursively searching for importable files in my dropbox
    When I have uploaded a directory with some files to my dropbox
     And that directory contains another directory with files
     And I start a new upload process
    Then I can choose all the files from all those directories from my dropbox instead of uploading them through the browser

  Scenario: Extracting the file name into metadata
    When I upload a file
    Then I want to have its original file name inside its metadata

