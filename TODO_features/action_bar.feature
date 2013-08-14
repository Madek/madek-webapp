Feature: Action bar
  
  # https://www.pivotaltracker.com/story/show/27418863
  @javascript
  Scenario: Locations where the action bar appears
    Given I am "Normin"
    When I look at one of these pages then I can see the action bar:
    | page_type              |
    | search results         |
    | my media entries       |
    | my sets page           |
    | my favorites           |
    | content assigned to me |
    | public content         |
    | set view               |

  # This scenario includes actually clicking each of the actions and trying
  # each of the behaviors.
  # https://www.pivotaltracker.com/story/show/27418863
  @javascript
  Scenario: Elements of the action bar
    Given I am "Petra"
    When I see the action bar
    Then I can choose between showing only sets
     And I can choose between showing only media entries
     And I can choose between showing media entries and sets
     And I can sort by created at
     And the results are sorted by created at 
     And I can sort by updated at
     And the results are sorted by updated at 
     And I can sort by title
     And the results are sorted by title 
     And I can sort by author
     And the results are sorted by author
    

