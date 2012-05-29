Feature: Batch edit selection

  In order to select multiple elements for batch editing
  As a normal and expert user
  I want to have the possibility to select / add multiple elements to the batch bar

  Background: Set up the world and personas
    Given I have set up the world a little
      And personas are loaded

  @javascript
  Scenario: Use the batch's "Select all" button
    Given I am "Normin"
      And I am on the homepage
     When I click the mediaset titled "Konzepte"
      And I use batch's deselect all
      And I use batch's select all
     Then I should see that all visible resources are in my batch bar
    
