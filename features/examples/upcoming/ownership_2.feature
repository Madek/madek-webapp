# These are the things we did not do during the first Onwership iteration.

Feature: Ownership II

  As a user
  I want to feel that I own my files
  So that I have a mental connection to them and am not confused by other people's files, or other files I have access to

  Background: Load the example data and personas
   Given I have set up the world
     And personas are loaded
     And I am "Normin"

  # https://www.pivotaltracker.com/story/show/23669443
  Scenario: The admin interface allows assigning permissions
    Given I am pending
    # Given a resource owned by "Susanne Schumacher"
      # And a resource owned by "Ramon Cahenzli"
     # When I go to the admin interface
      # And I assign the resources to "Susanne Schumacher"
     # Then both resources are owned by "Susanne Schumacher"
