Feature: Teaser set

  Background: Load the example data and personas
    Given personas are loaded

  @javascript
  Scenario: Image tableau on welcome page
    When I go to the welcome page
    Then I should see a selection of the images of the teaser set
    When I go again to the welcome page
    Then I should see a new selection of the images of the teaser set
    When I see the images of the teaser set
    Then I see a grey shadow over the images
    When I hover on an image
    Then the grey shadow is disappering
 	And the title and the author of the image is displayed