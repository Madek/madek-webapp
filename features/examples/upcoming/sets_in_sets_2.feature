Feature: Sets in Sets II

  Background: Set up the world with a user and logging in
    Given I have set up the world
      And a user called "Max" with username "max" and password "moritz" exists
      And I log in as "max" with password "moritz"
      And I am logged in as "max"

  # We should do this when we attack the rest of the technical debt, do optimization
  # Scenario: The sets in sets tool loads quickly enough
    # When I open the sets in sets tool
    # Then the tool loads in less than 2 seconds

  # https://www.pivotaltracker.com/story/show/22464659
  # Pts: ?
  # We don't think this should be implemented as suggested -- discuss
  # Includes implementing this through the API
  Scenario: Choosing which contexts are valid for a set
   Given a context called "Landschaftsvisualisierung"
     And a context called "Zett"
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" which is child of "Landschaften" and "Zett"
     And I can edit the set "Zett über Landschaften"
    When I view the set "Zett über Landschaften"
    Then I see the available contexts "Landschaftsvisualisierung" and "Zett"
    When I assign the context "Zett" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Zett"
    When I assign the context "Landschaftsvisualisierung" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Landschaftsvisualisierung"
     And the set still has its other contexts as well

  # https://www.pivotaltracker.com/story/show/22464659
  # Pts: ?
  # To discuss
  Scenario: Viewing which contexts a set could have
   Given a context called "Landschaftsvisualisierung"
     And a context called "Zett"
     And a context called "Games"
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" which is child of "Landschaften" and "Zett"
    When I view the set "Zett über Landschaften"
    Then I can choose to see more details about the context "Zett"
     And I can choose to see more details about the context "Landschaftsvisualisierung"
     And I can choose to see more details about the context "Games"
