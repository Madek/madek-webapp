Feature: Curated set / Gallery

  @javascript @slow
  Scenario: Using the set highlight editing option
    Given I am "Normin"
     And I open a set that I can edit which has children
    Then I see the the option to edit the highlights for this set
     And I can select which children to highlight
    When I select a resource to be highlighted
    Then the resource is highlighted
  
  @javascript
  Scenario: Not seeing the set highlight editing option
    Given I am "Petra"
     And I open a set that I can not edit which has children
    Then I don't see the option to edit the highlights for this set
  
  @javascript @slow
  Scenario: Viewing a set that has highlighted resources
    Given I am "Normin"
     And I open a set that I can edit which has children
    Then I see the the option to edit the highlights for this set
     And I can select which children to highlight
     And I select a resource to be highlighted
    Then the resource is highlighted
    When I view a set with highlighted resources
    Then I see the highlighted resources in bigger size than the other ones
     And I see the highlighted resources twice, once in the highlighted area, once in the "set contains" list

  @javascript @upcoming
  Scenario: Default title of the highlighted elements
    When I see a set with highlighted resources
    Then the default title is "Hervorgehobene Inhalte"
    
  @javascript @upcoming
  Scenario: Set the title for the highlighted elements
    Given I am "Normin"
     When I open a set that I can edit which has children
      And I open the highlight dialog
     Then I can set the title for the highlighted elements