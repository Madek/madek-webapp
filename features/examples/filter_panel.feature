Feature: Filter panel

  As a MAdeK user
  I want to be able to filter resources on many different pages
  So that I can get a good overview of all the things in the system
  And I can reduce my overview depending on various filter criteria

  @upcoming
  Scenario: Where the filter panel appears
    When I look at one of these pages, then I can see the filter panel:
    | page_type              |
    | my media entries       |
    | my sets page           |
    | my favorites           |
    | content assigned to me |
    | public content         |
    | set view               |
    Then I can also choose to see the filter panel
    When I look at one of these pages, then the filter panel is already expanded:
    | search results         |

  @upcoming
  Scenario: Criteria of the filter panel
    Given a list contains resources that have values in a meta key of type "MetaDatumMetaTerms"
    Then I can filter by the values for that particular key
    #Given a list contains resources that have values in a meta key of type "MetaDatumDepartments"
    #Then I can filter by the values for that particular key
    #Given a list contains resources that have values in a meta key of type "MetaDatumKeywords"
    #Then I can filter by the values for that particular key
    #And I can filter by permissions
    #And I can filter by image format
    #And I can filter by owner
    #And I can filter by group
  
  @upcoming
  Scenario: Behavior when selecting a filter
    When I select a value to filter by
    Then I see all the values that can be filtered by
    And I all the values that can no longer be filtered by, and they are deactivated
    When I deselect the value
    Then I see all the values that can be filtered by
    And none of the values are deactivated

  @upcoming
  Scenario: Rules for when a MetaKey is displayed in the filter panel
    Given a list of resources
    When I see the filter panel
    Then I see a list of MetaKeys the resources have values for
    And I don't see the MetaKeys the resources have no values for

  @upcoming
  Scenario: Result counts for each value
    Given I see a filtered list of resources
    Then I see the match count for each value
    And the values are sorted by match count

  @upcoming
  Scenario: Filtering contents of a set that has many things in it
    Given I am "Liselotte"
    When I open a set that has children
    Then I can expand the filter panel
    And I see a list of MetaKeys
    And I can open a particular MetaKey
    And I can filter by the values of that key

  @upcoming
  Scenario: Filtering after searching
    Given I am "Liselotte"
    When I search for "Landschaft"
    Then I see a matching search result
    When I filter "Schlagworte zu Inhalt und Motiv" by "kalt warm"
