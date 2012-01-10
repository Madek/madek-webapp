Feature: Sets in Sets

  Background: To be defined

  # Pivotal: https://www.pivotaltracker.com/story/show/22779469
  @current
  Scenario: Adding a set to a set, removing a set from a set
    Given I am on a page showing a set
     When I try to add this set to another set
     Then I am less confused than last week

  # Pivotal: https://www.pivotaltracker.com/story/show/22779469
  @current
  Scenario: Information I see when I open the sets in sets tool
     When I open the sets in sets tool
     Then the tool appears quickly
      And I see all sets I can edit
      And I can filter for my sets
      And I can see the owner of each set
      And I can see that selected sets are already highlighted
      And I can choose to see additional information
      And I can see enough information to differentiate between similar sets

  # Pivotal: https://www.pivotaltracker.com/story/show/22421449
  @current
  Scenario: Moving resources into or out of multiple sets at the same time
    Given multiple resources are in my selection
      And they are in various different sets
     When I open the sets in sets tool
     Then I see the sets none of them are in
      And I see the sets some of them are in
      And I see the sets all of them are in
      And I can add all of them to one set
      And I can remove all of them from one set

    # https://www.pivotaltracker.com/story/show/12828561
    @current
    Scenario: Add a set to my favorites
     Given I see some sets
      When I add them to my favorites
      Then they are in my favorites

    # https://www.pivotaltracker.com/story/show/22576523
    @current
    Scenario: Viewing a context
      Given a context
       When I look at a page describing this context
       Then I see all the keys that can be used in this context
        And I see all the values those keys can have
        And I see an excerpt of the most used metadata from media entries using this context

    # https://www.pivotaltracker.com/story/show/22464659
    @current
    Scenario: Choosing which metadata contexts are valid for a set
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
    @current
    Scenario: Viewing which contexts a set has
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

