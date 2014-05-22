Feature: Context

  As a MAdeK user
  I want to work with contexts
  So that I can use specified vocabulary

  Background: 
    Given I am signed-in as "Normin"

  Scenario: See a list of contexts
    When I visit "/my"
    Then I see a preview list of contexts that are connected with media resources that I can access
    And for each context I see the label and description and the link to that context
    When I go to the my contexts page
    Then I see a list with all contexts that are connected with media resources that I can access
    And for each context I see the label and description and the link to that context

  @firefox
  Scenario: Open a specific context
    When I open a specific context
    Then I see the title of the context
      And I see the description of the context
    When I click on "Inhalte"
    And I pry
    Then I see all resources that are using that context

  @jsbrowser 
  Scenario: Highlight used vocabulary
    When I open a specific context
     And I use the highlight used vocabulary action
    Then the unused values are faded out

  Scenario: Interact with the abstract slider of a context 
    When I open a specific context
    Then I see all values that are at least used for one resource
    When I open a specific context
     And I go to the context's abstract page
    Then I see all values that are at least used for one resource
