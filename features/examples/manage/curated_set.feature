Feature: Curated set / Gallery

  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded
  
  @javascript
  Scenario: Using the set highlight editing option
    When I am "Normin"
     And I open a set that I can edit which has children
    Then I see the the option to edit the highlights for this set
     And I can select which children to highlight
    When I select a resource to be highlighted
    Then the resource is highlighted
  
  @javascript
  Scenario: Not seeing the set highlight editing option
    When I am "Petra"
     And I open a set that I can not edit which has children
    Then I don't see the option to edit the highlights for this set
  
  @javascript
  Scenario: Viewing a set that has highlighted resources
    When I am "Normin"
    When I view a set with highlighted resources
    Then I see the highlighted resources in bigger size than the other ones
     And I see the highlighted resources twice, once in the highlighted area, once in the "set contains" list
