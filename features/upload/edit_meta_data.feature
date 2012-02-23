Feature: Edit MetaData during upload/import

  In order to edit meta data during the upload/import
  As a user
  I want to have a complete upload/import step where i can edit the meta data of the files im importing
  
  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded
      And I am "Normin"

  @javascript
  Scenario: Having "save metadata" button twice on the edit meta data screen
    When I upload a file
     And I go to the upload edit page
    Then I should see the save and continue button twice