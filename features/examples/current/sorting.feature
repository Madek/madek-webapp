Feature: Sorting Media Resources

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Normin"

  Scenario: Sorting Media Resources by title
    Given I see a list of resources
    When I sort by title
    Then I see that the resources are sorted by title alphanumericaly (0-9-A-Z) accending per default

  Scenario: Sorting Media Resources by author
    Given I see a list of resources
    When I sort by authors
    Then I see that the resources are sorted by authors lastname alphabeticaly (A-Z)