Feature: Context

  As a MAdeK user
  I want to work with contexts
  So that I can use specified vocabulary

  Background: 
    Given I am signed-in as "Normin"

  @clean
  Scenario: See a list of contexts
    When I go to the explore page
    Then I see a preview list of contexts that are connected with media resources that I can access
    And for each context I see the label and description
    When I go to the explore contexts page
    Then I see a list with all contexts that are connected with media resources that I can access
    And for each context I see the label and description

  @clean
  Scenario: Open a specific context
    When I open a specific context
    Then I see the title of the context
     And I see the description of the context
     And I see all resources that are inheritancing that context and have any meta data for that context
     And I can go to the abstract of that context
     And I can go to the vocabulary of that context

  @jsbrowser @clean
  Scenario: Highlight used vocabulary
    When I open a specific context
     And I go to the context's vocabulary page
     And I use the highlight used vocabulary action
    Then the unused values are faded out

  @clean
  Scenario: Interact with the abstract slider of a context 
    When I'm on the context's abstract page
    Then I see all values that are at least used for one resource
    When I open a specific context
     And I go to the context's abstract page
    Then I see all values that are at least used for one resource