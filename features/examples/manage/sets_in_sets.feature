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
  Scenario: Moving ressources into or out of multiple sets at the same time
    Given multiple resources are in my selection
      And they are in various different sets
     When I open the sets in sets tool
     Then I see the sets none of them are in
      And I see the sets some of them are in
      And I see the sets all of them are in
      And I can add all of them to one set
      And I can remove all of them from one set

   # https://www.pivotaltracker.com/story/show/21269559
#   Scenario:

