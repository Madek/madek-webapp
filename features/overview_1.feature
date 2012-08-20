Feature: Overview I
  
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
     And I can filter content by any permissions
     And I can filter content by my content
     And I can filter content assigned to me
     And I can filter content that is public
     And I can sort by created at
     And I can sort by updated at
    
  # This scenario includes actually clicking each of the actions and trying
  # each of the behaviors.
  # https://www.pivotaltracker.com/story/show/27418863
  @javascript @wip
  Scenario: Layout i can set in the action bar
    Given I am "Normin"
     When I see the action bar
      And I can switch the layout of the results to the grid view
      And I can switch the layout of the results to the list view 
      And I can switch the layout of the results to the miniature view 

  # https://www.pivotaltracker.com/story/show/27418863
  @javascript
  Scenario: Picking any action from the action bar changes the page I am on
    Given I am "Normin"
     When I change any of the settings in the bar then i am forwarded to a different page url

  # https://www.pivotaltracker.com/story/show/27418863
  @javascript
  Scenario: Content counter
   Given I am "Normin"
    When I go to set view
    Then the counter is formatted as "N von M für Sie sichtbar"
    When I go to search results
     And the grid layout is active
    Then the counter is formatted as "N Resultate"
