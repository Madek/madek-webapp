Feature: Filter set

  As a MAdeK user
  I want to be able to save the filter settings I make
  So that I can create new sets that display exactly that filtered content
  And the set updates to reflect any more or less search results

  For example: I filter by 'Anything from genre "Photography"'. Then I save
  this search into a filter set, so that whenever I navigate to that set, I
  see any content that is in genre "Photography".

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Normin"

  # https://www.pivotaltracker.com/story/show/33961905
  @javascript
  Scenario: Saving a filter configuration as a filtered set
    When I see a filtered list of resources
    Then I can choose to save the configuration of the filters as a new set
    When I choose to save the filter configuration
    Then I am prompted for the name of the new set that is thus created

  # https://www.pivotaltracker.com/story/show/33961905
  @poltergeist
  Scenario: Actions available for a filter set
    When I look at a filter set
    Then I can open the context actions drop down and see the following actions in the following order:
    |action|
    |edit|
    |permissions|
    |favorite|
    |add to set|
    |edit changes to filter settings|
    # |set highlight|
    # |set cover|
    # |save display settings|
    |delete|
