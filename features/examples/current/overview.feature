Feature: Overview I
  
  
  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded

  # https://www.pivotaltracker.com/story/show/27418863
  @wip
  Scenario: Locations where the action bar appears
    Given I am "Normin"
    When I look at one of these pages:
    | page_type              |
    | Search results         |
    | My media entries       |
    | My sets                |
    | My favorites           |
    | Content assigned to me |
    | Public content         |
    | Set view               |
    Then I can see the action bar

  # This scenario includes actually clicking each of the actions and trying
  # each of the behaviors.
  # https://www.pivotaltracker.com/story/show/27418863
  @wip
  Scenario: Elements of the action bar
    Given I am "Normin"
    When I see the action bar
    Then I can choose between showing:
    | type                   |
    | Only sets              |
    | Only media entries     |
    | Media entries and sets |
    And I can filter content by:
    | permission             |
    | Any permissions        |
    | My content             |
    | Content assigned to me |
    | Public content         |
    And I can sort by:
    | sort order |
    | Created at |
    | Updated at |
    | Random     |
    And I can switch the layout of the results:
    | layout    |
    | Grid      |
    | List      |
    | Mini-grid |

  # https://www.pivotaltracker.com/story/show/27418863
  @wip
  Scenario: Picking any action from the action bar changes the page I am on
    When I am on a page with an action bar
    And I change any of the settings in the bar
    Then I am forwarded to a different page
    And I cannot make multiple changes in one go

  # https://www.pivotaltracker.com/story/show/27418863
  @wip
  Scenario: Content counter
    When I look at a set
    Then the counter is formatted as "n von m für Sie sichtbar"
    And when I look at a list of search results
    Then the counter is formatted as "n Resultate"

  # https://www.pivotaltracker.com/story/show/21438575
  @wip
  Scenario: Displaying the appropriate placeholder icon for a file that can't be previewed
    Given the system is set up
    Then each of the following media types has its own representing icon according to the mappings in the file "config/mime_icons.yml"
