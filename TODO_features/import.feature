# https://www.pivotaltracker.com/story/show/24559683 -> Plupload statt eigenes import-Widget
Feature: Import 
  As a user
  I want to import files to the system
  So that I can share my files with everyone

  Background: Load the example data and personas
    Given I am "Normin"
      And all users have dropboxes

  # https://www.pivotaltracker.com/story/show/24559407 -> Zugriffsberechtigungen beim import: Gleich wie bei Medieneintrag editieren
  @poltergeist 
  Scenario: Setting permissions during import
    When I import a file
    Then the file is attached to a media entry
     And I can set the permissions for the media entry during the import process
 
  @poltergeist 
  Scenario: Filling in core metadata during import
    When I import a file
    Then the file is attached to a media entry
    When I go to the import edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                    |
     | Titel                           | Test image for importing |
     | Autor/in                        | Hans Franz               |
     | Datierung                       | 2011-08-08               |
     | Schlagworte zu Inhalt und Motiv | some                     |
     | Schlagworte zu Inhalt und Motiv | test                     |
     | Rechte                       | Tester                   |
     
  # https://www.pivotaltracker.com/story/show/24559377 -> User kann beim import beim Vergeben der Metadaten die Werte zu Titel, Autor, Datierung, Schlagworte und Rechten von einem auf alle Medieneinträge übertrage
  @poltergeist 
  Scenario: Assigning one value to all imported things
    When I import several files
     When I go to the import edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                                    |
     | Titel                           | Test image for mass assignment of values |
     | Autor/in                        | Hans Franzfriedrich                      |
     | Datierung                       | 2011-08-09                               |
     | Schlagworte zu Inhalt und Motiv | other                                    |
     | Schlagworte zu Inhalt und Motiv | example                                  |
     | Rechte                       | Tester Two                               |
    Then I can assign the Title to all the other files I just imported
    Then I can assign the Copyright to all the other files I just imported

  # Feature exists already, but needs this test
  @poltergeist 
  Scenario: Adding to a set during import
    When I import a file
    Then the file is attached to a media entry
     And I add the media entry to a set called "Konzepte"

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @poltergeist 
  Scenario: importing large files
    When I import a file with a file size greater than 1.4 GB
    Then the system gives me a warning telling me it's impossible to import so much through the browser
     And the warning includes instructions for an FTP import

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @poltergeist 
  Scenario: importing via a dropbox
    When I have imported some files to my dropbox
     And I start a new import process
    Then I can choose files from my dropbox instead of importing them through the browser

  # https://www.pivotaltracker.com/story/show/24559261 -> Dateien zum Import aus einer Dropbox holen 
  @poltergeist 
  Scenario: Recursively searching for importable files in my dropbox
    When I have imported a directory containing files to my dropbox
     And I start a new import process
    Then I can choose files from my dropbox instead of importing them through the browser
  
  # https://www.pivotaltracker.com/story/show/24564545 -> import abbrechen können   
  @javascript
  Scenario: Cancelling my import
    When I have started importing some files
     And I cancel the import
    Then the import process ends
     And the imported files are still there
  
  # https://www.pivotaltracker.com/story/show/24564505 -> Dateien nach import aber vor Import löschen   
  @javascript
  Scenario: Deleting files before, during and after import without completing the import
    When I importing some files from the dropbox and from the filesystem
     And I delete some fo those after the import
     And I wait for the AJAX magic to happen
    Then those files are deleted
     And only the rest of the files are available for import
    
  # https://www.pivotaltracker.com/story/show/14696355 -> Angabe des Original-Dateinamens bei einem Medieneintrag
  @poltergeist
  Scenario: Extracting the file name into metadata
    When I import a file
    Then I want to have its original file name inside its metadata

  # https://www.pivotaltracker.com/story/show/24559317 -> Highlighting für Felder, die nicht validieren (required)
  @poltergeist 
  Scenario: Fields that don't validate should be highlighted
    When I import a file
      When I go to the import edit
      And I fill in the metadata for entry number 1 as follows:
      | label | value                       |
      | Titel | Test image for highlighting |
      And I try to continue in the import process
      Then I see an error message "Inhalte mit unvollständigen Metadaten!"
      And the field "Rechte" is highlighted as invalid

  # https://www.pivotaltracker.com/story/show/25923269
  @poltergeist 
  Scenario: Sequential batch editor for importing many files
    When I import several files
      When I go to the import edit
      Then I see a list of my imported files
       And I can jump to the next file
       And I can jump to the previous file

  # https://www.pivotaltracker.com/story/show/25923269
  @javascript
  Scenario: Filtering only media entries with missing metadata in the sequential batch editor
    When I import several files
     When I go to the import edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                    |
     | Titel                           | Test image for importing |
     | Rechte                       | Tester                   |
    Then I see a list of my imported files
     And the files with missing metadata are marked
     And I can choose to list only files with missing metadata
    When I choose to list only files with missing metadata
    Then only files with missing metadata are listed

  @javascript
  Scenario: meta terms in the context import
    Given MetaTerms are existing in the import context
     And I am "Normin"
    When I import a file
    Then I can set values for the meta data from type meta terms

  @poltergeist
	Scenario: Dependencies among the pulldown menus of the copyright field
    When I import several files
     When I go to the import edit
     And I fill in the metadata for entry number 1 as follows:
     | label                           | value                                    |
     | Titel                           | Test image for mass assignment of values |
     | Autor/in                        | Hans Franzfriedrich                      |
     | Datierung                       | 2011-08-09                               |
     | Schlagworte zu Inhalt und Motiv | other                                    |
     | Schlagworte zu Inhalt und Motiv | example                                  |
    Then I can assign the Title to all the other files I just imported
		When I select a copyright status from the predefined ones and this status has values for each of its fields
		And then switch to another copyright status that has no or blank values for any of its fields
		Then each of these fields of the copyright status are cleared
