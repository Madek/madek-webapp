Feature: Splashscreen

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded

  @javascript
  Scenario: Image rotation on splashscreen
    When I go to the home page
    Then I should see an image rotation of the splashscreen set