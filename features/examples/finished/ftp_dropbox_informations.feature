Feature: FTP-Dropbox informations on the upload page

  In order to get informations how and when to use the dropbox on the upload page
  As a user
  I want to have those informations available
  
  Background: Load the example data and personas
    Given I have set up the world a little
      And I am "Normin"

  @javascript
  Scenario: Getting the information to contact the IT-Department when i need help setting up a ftp connection
    When I go to the upload page
     And I open the FTP information dialog
    Then I should see "Für Hilfe beim Zugang über FTP, wenden Sie sich an Ihre IT-Abteilung"
