Feature: Overview II
  
  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded

  # This scenario includes actually clicking each of the actions and trying
  # each of the behaviors.
  # https://www.pivotaltracker.com/story/show/26719419
  @javascript
  Scenario: Layout i can set in the action bar
    Given I am "Normin"
     When I see the action bar
      And I can switch the layout of the results to the grid view
      # And I can switch the layout of the results to the list view # NOTE: not yet implemented/commited  
      And I can switch the layout of the results to the miniature view # NOTE: not yet implemented/commited
