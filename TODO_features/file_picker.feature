Feature: File picker for uploading files

  In order to upload files to the application
  As a user
  I want to be able to pick files from my filesystem
  
  Background: Load the example data and personas
    Given I am "Normin"

  @javascript
  Scenario: Picking a file that's size is 0 bytes
    When I go to the upload page
     And I atach a file with a size of 0 bytes
    Then I should see "Problem mit der ausgewählten Datei"
     And I should see "Dateigrösse ist Null"
     And I the file of 0 bytes was not added to the upload queue 
