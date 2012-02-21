# https://www.pivotaltracker.com/story/show/24559683 -> Plupload statt eigenes Upload-Widget
Feature: Upload
  As a user
  I want to upload files to the system
  So that I can share my files with everyone

  Background: Load the example data and personas
	Given I have set up the world
      And personas are loaded
      And I am "Normin"

  # https://www.pivotaltracker.com/story/show/24559407 -> Zugriffsberechtigungen beim Upload: Gleich wie bei Medieneintrag editieren
  @committed @javascript
  Scenario: Setting permissions during upload
    When I upload a file
    Then the file is attached to a media entry
     And I can set the permissions for the media entry during the upload process

  @javascript
  Scenario: Filling in core metadata during upload
    When I upload a file
    Then the file is attached to a media entry
     And I fill in the metadata in the upload form as follows:
     |label                              |value|
     |Titel                              |Test image for uploading|
     |Autor/in                           |Hans Franz|
     |Datierung                          |2011-08-08|
     |Schlagworte zu Inhalt und Motiv    |some|
     |Schlagworte zu Inhalt und Motiv    |test|
     |Copyright                          |Tester|
     
  # https://www.pivotaltracker.com/story/show/24559377 -> User kann beim Upload beim Vergeben der Metadaten die Werte zu Titel, Autor, Datierung, Schlagworte und Rechten von einem auf alle Medieneinträge übertrage
  Scenario: Assigning one value to all uploaded things
    When I upload several files
     And I enter metadata for the first file
     And I fill in the metadata in the upload form as follows:
     |label                              |value|
     |Titel                              |Test image for mass assignment of values|
     |Autor/in                           |Hans Franzfriedrich|
     |Datierung                          |2011-08-09|
     |Schlagworte zu Inhalt und Motiv    |other|
     |Schlagworte zu Inhalt und Motiv    |example|
     |Copyright                          |Tester Two|
    Then I can assign the same values to all the other files I just uploaded

  # Feature exists already, but needs this test
  @javascript
  Scenario: Adding to a set during upload
    When I upload a file
    Then the file is attached to a media entry
     And I add the media entry to a set called "Konzepte"

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @committed @javascript
  Scenario: Uploading large files
    When I upload a file with a file size greater than 1.4 GB
    Then the system gives me a warning telling me it's impossible to upload so much through the browser
     And the warning includes instructions for an FTP upload

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @committed @javascript
  Scenario: Uploading via a dropbox
    When I have uploaded some files to my dropbox
     And I start a new upload process
    Then I can choose files from my dropbox instead of uploading them through the browser

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @committed @javascript
  Scenario: Recursively searching for importable files in my dropbox
    When I have uploaded a directory containing files to my dropbox
     And I start a new upload process
    Then I can choose files from my dropbox instead of uploading them through the browser
  
  # https://www.pivotaltracker.com/story/show/24564545 -> Upload abbrechen können   
  @committed @javascript
  Scenario: Cancelling my upload
    When I have started uploading some files
     And I cancel the upload
    Then the upload process ends
     And the uploaded files are still there
  
  # https://www.pivotaltracker.com/story/show/24564505 -> Dateien nach Upload aber vor Import löschen   
  @committed @javascript
  Scenario: Deleting files before, during and after upload without completing the import
    When I uploading some files from the dropbox and from the filesystem
     And I delete some of those files during the upload
     And I delete some fo those after the upload
    Then those files are deleted
     And only the rest of the files are available for import
    
  # https://www.pivotaltracker.com/story/show/14696355 -> Angabe des Original-Dateinamens bei einem Medieneintrag
  @javascript
  Scenario: Extracting the file name into metadata
    When I import a file
    Then I want to have its original file name inside its metadata

  # https://www.pivotaltracker.com/story/show/24559359 -> Datierung aus Kameradatum (EXIF/IPTC) übernehmen (Erstellungsdatum)
  Scenario: Extracting the camera date into metadata
    When I upload a file
    Then I want to have the date the camera took the picture on as the creation date
    
  # https://www.pivotaltracker.com/story/show/24559317 -> Highlighting für Felder, die nicht validieren (required)
  Scenario: Fields that don't validate should be highlighted
    When I upload a file
     And I enter metadata for the file
     And I fill in the metadata in the upload form as follows:
     |label                              |value|
     |Titel                              |Test image for highlighting|
     And I try to continue in the import process
    Then I see an error message
     And the field "Copyright" is highlighted as invalid
