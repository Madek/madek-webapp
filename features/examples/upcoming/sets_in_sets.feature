Feature: Sets in Sets III

  Background: Load the example data and personas
	Given I have set up the world
      And personas are loaded

  # https://www.pivotaltracker.com/story/show/22576523
  # https://www.pivotaltracker.com/story/show/23800945
  Scenario: Viewing a context
    Given a context
     When I look at a page describing this context
     Then the page's look is consistent with the rest of the application
      And I see all the keys that can be used in this context
      And I see all the values those keys can have
      And I see an abstract of the most assigned values from media entries using this context

  # https://www.pivotaltracker.com/story/show/23825857
  Scenario: Switch between all sets and main sets on the page 'my sets'
    Given a few sets
     When I view a list of my sets
     Then I see a list of my top-level sets
      And I can switch to a list of all my sets
     When I view a list of all my sets
     Then I see all my sets
