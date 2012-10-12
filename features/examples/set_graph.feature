Feature: Set Graph

  As a MAdeK user

  Background: Load the example data and personas
    Given personas are loaded
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

  @javascript
  Scenario: Zoom and move instructions
    When I see the set graph
    Then I see the zoom and move instructions
     And the instructions say "Klicken und ziehen, um die Ansicht zu bewegen. Scrollen, um hinein- und herauszuzuoomen."

  @javascript
  Scenario: Seeing the batch edit bar
    When I see the set graph
    Then I also see the batch edit bar
     And I can add the resource shown in the inspector to my batch selection

  @javascript
  Scenario: Overlays with additional information in the set graph
    When I see the set graph
    Then I can choose to see icons for permissions on each node of the graph
     And I can choose to see icons for favorites on each node of the graph

  @javascript
  Scenario: Automatic element-scaling on viewport scaling
    When I see the set graph
     And I change the window width
    Then the set graph element is scaling to the new width
    When I change the window height
    Then the set graph element is scaling to the new height
     And the inspector panel shows more child elements corresponding to the new height

