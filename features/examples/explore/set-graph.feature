Feature: Set Graph

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Normin"

  @javascript
  Scenario: See the layout switcher for set graph layout
    When I see a list of my sets
    Then I see a switcher for the set graph layout in the layout switcher
    When I switch the layout to the set graph
    Then I can see the set graph

  @javascript
  Scenario: What i see when i switch to the set graph layout
    When I see the set graph
    Then I see that the set graph is integrated in the site layout
     And I see a panel inspector on the right side
     And I dont see a "sort by" option
  
  @javascript
  Scenario: What i see in the set graph itself
    When I see the set graph
    Then I see the realtionship between my sets
     #wip And I see a zoom panel
     #wip And I see a navigation panel (up, down, left, right)

  # @wip
  # Scenario: Using the zoom panel
  #   When I see the set graph
  #    And I click "zoom in" then the graph zooms in 
  #    And I click "zoom out" then the graph zooms out

  # @wip
  # Scenario: Using the navigation panel
  #   When I see the set graph
  #   When I click "move up" 
  #   Then the graph moves down 
  #   When I click "move down" 
  #   Then the graph moves up 
  #   When I click "move left" 
  #   Then the graph moves right 
  #   When I click "move right" 
  #   Then the graph moves left 

  @javascript
  Scenario: What I see on the graph
    When I see the set graph
    Then each resources is represented by thumbnail image and title
     And the relationship between the sets is represented by an connection line
     And an arrow is pointing from the parent to a child
  
  @javascript
  Scenario: Swaping graph elements
    When I see the set graph
     And I hover a graph element in the background
    Then this element swaps to the foreground

  @javascript
  Scenario: When I click a resource in the set graph
    When I see the set graph
     And I click a element in the set graph
    Then the element is highlighted
     And the inspector panel shows informations about the selected element


