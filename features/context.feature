Feature: Context

  As a MAdeK user
  I want to work with contexts
  So that I can use specified vocabulary

  Scenario: See a list of contexts
    When I go to the explore page
    Then I see a list of contexts that are connected with media sets that i can see
    And for each context I see the label and description

  Scenario: Open a specific context
    When I go to the explore page
     And I open a context
    Then I see the title of the context
     And I see the description of the context
     And I see all resources that have any value for any key of that context
     And I see the abstract tab
    When I click the abstract tab
    Then I see the abstract of that context
     And I see the vocabulary tab
    When I click the vocabulary tab
    Then I see the vocabulary of that context

  Scenario: Highlight used vocabulary
    When I'm on the context's vocabulary page
     And I use the highlight used vocabulary action
    Then the unused values are faded out

  Scenario: Interact with the abstract slider of a context 
    When I'm on the context's abstract page
    Then I see all values that are at least used for one resource

  
     