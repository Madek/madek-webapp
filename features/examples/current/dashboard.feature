Feature: Login

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Petra"

  @javascript
  Scenario: The three blocks of content available on the dashboard
    Given I am on the dashboard
     Then I see a block of resources showing my content
      And I can choose to continue to a list of all my content
      And I see a block of resources showing content assigned to me
      And I can choose to continue to a list of all content assigned to me      
      And I see a block of resources showing content available to the public
      And I can choose to continue to a list of all content available to the public

