# https://www.pivotaltracker.com/story/show/24559683 -> Plupload statt eigenes Upload-Widget
Feature: Upload
  As a user
  I want to upload files to the system
  So that I can share my files with everyone

  Background: Load the example data and personas
    Given I have set up the world a little
      And I am "Normin"
      And all users have dropboxes

  # https://www.pivotaltracker.com/story/show/24559407 -> Zugriffsberechtigungen beim Upload: Gleich wie bei Medieneintrag editieren
  @javascript
  Scenario: Setting permissions during upload
    When I upload a file
    Then the file is attached to a media entry
     And I can set the permissions for the media entry during the upload process

  @javascript
  Scenario: Filling in core metadata during upload
    When I upload a file
    Then the file is attached to a media entry
    When I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                    |
     | Titel                           | Test image for uploading |
     | Autor/in                        | Hans Franz               |
     | Datierung                       | 2011-08-08               |
     | Schlagworte zu Inhalt und Motiv | some                     |
     | Schlagworte zu Inhalt und Motiv | test                     |
     | Rechte                       | Tester                   |
     
  # https://www.pivotaltracker.com/story/show/24559377 -> User kann beim Upload beim Vergeben der Metadaten die Werte zu Titel, Autor, Datierung, Schlagworte und Rechten von einem auf alle Medieneinträge übertrage
  @javascript
  Scenario: Assigning one value to all uploaded things
    When I upload several files
     When I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                                    |
     | Titel                           | Test image for mass assignment of values |
     | Autor/in                        | Hans Franzfriedrich                      |
     | Datierung                       | 2011-08-09                               |
     | Schlagworte zu Inhalt und Motiv | other                                    |
     | Schlagworte zu Inhalt und Motiv | example                                  |
     | Rechte                       | Tester Two                               |
    Then I can assign the Title to all the other files I just uploaded
    Then I can assign the Copyright to all the other files I just uploaded

  # Feature exists already, but needs this test
  @javascript
  Scenario: Adding to a set during upload
    When I upload a file
    Then the file is attached to a media entry
     And I add the media entry to a set called "Konzepte"

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @javascript
  Scenario: Uploading large files
    When I upload a file with a file size greater than 1.4 GB
    Then the system gives me a warning telling me it's impossible to upload so much through the browser
     And the warning includes instructions for an FTP upload

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @javascript
  Scenario: Uploading via a dropbox
    When I have uploaded some files to my dropbox
     And I start a new upload process
    Then I can choose files from my dropbox instead of uploading them through the browser

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @javascript
  Scenario: Recursively searching for importable files in my dropbox
    When I have uploaded a directory containing files to my dropbox
     And I start a new upload process
    Then I can choose files from my dropbox instead of uploading them through the browser
  
  # https://www.pivotaltracker.com/story/show/24564545 -> Upload abbrechen können   
  @javascript
  Scenario: Cancelling my upload
    When I have started uploading some files
     And I cancel the upload
    Then the upload process ends
     And the uploaded files are still there
  
  # https://www.pivotaltracker.com/story/show/24564505 -> Dateien nach Upload aber vor Import löschen   
  @javascript
  Scenario: Deleting files before, during and after upload without completing the import
    When I uploading some files from the dropbox and from the filesystem
     And I delete some fo those after the upload
    Then those files are deleted
     And only the rest of the files are available for import
    
  # https://www.pivotaltracker.com/story/show/14696355 -> Angabe des Original-Dateinamens bei einem Medieneintrag
  @javascript
  Scenario: Extracting the file name into metadata
    When I import a file
    Then I want to have its original file name inside its metadata

    
  # https://www.pivotaltracker.com/story/show/24559317 -> Highlighting für Felder, die nicht validieren (required)
  @javascript
  Scenario: Fields that don't validate should be highlighted
    When I upload a file
      When I go to the upload edit
      And I fill in the metadata for entry number 1 as follows:
      | label | value                       |
      | Titel | Test image for highlighting |
      And I try to continue in the import process
      Then I see an error message "Inhalte mit unvollständigen Metadaten!"
      And the field "Rechte" is highlighted as invalid

  # https://www.pivotaltracker.com/story/show/25923269
  @javascript
  Scenario: Sequential batch editor for uploading many files
    When I upload several files
      When I go to the upload edit
      Then I see a list of my uploaded files
       And I can jump to the next file
       And I can jump to the previous file

  # https://www.pivotaltracker.com/story/show/25923269
  @javascript
  Scenario: Filtering only media entries with missing metadata in the sequential batch editor
    When I upload several files
     When I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                    |
     | Titel                           | Test image for uploading |
     | Rechte                       | Tester                   |
    Then I see a list of my uploaded files
     And the files with missing metadata are marked
     And I can choose to list only files with missing metadata
    When I choose to list only files with missing metadata
    Then only files with missing metadata are listed
