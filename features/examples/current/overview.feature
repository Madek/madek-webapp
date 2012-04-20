Feature: Overview II
  
  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded

  # https://www.pivotaltracker.com/story/show/21438575
  Scenario: Displaying the appropriate placeholder icon for a file that can't be previewed
    Given the system is set up
    Then each of the following media types has its own representing icon according to the mappings in the file "config/mime_icons.yml"
