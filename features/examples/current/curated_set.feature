Feature: Curated set / Gallery

  Scenario: Highlighting a specific resource in a set
    When I edit a set that has resources
    Then I can select which resources to highlight

  Scenario: Seeing the set highlight editing option
    When I have edit permission for a set
     And I view that set
    Then I see the the option to edit the highlights for this set

  Scenario: Not seeing the set highlight editing option
    When I don't have edit permission for a set
     And I view that set
    Then I don't see the option to edit the highlights for this set

  Scenario: Viewing a set that has highlighted resources
    When I view a set with highlighted resources
    Then I see the highlighted resources in greater size than the other ones
     And I see the highlighted resources in the list of resources for this set

  @glossary
  Scenario: Highlighted resource
    When a resource is highlighted
    Then it is additionally displayed in a separate section of a set
     And it is displayed in a more highlighted (larger, different color...) way than others
