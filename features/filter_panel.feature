Feature: Filter panel

  As a MAdeK user
  I want to be able to filter resources on many different pages
  So that I can get a good overview of all the things in the system
  And I can reduce my overview depending on various filter criteria

  @javascript
  Scenario: Where the filter panel appears
   Given I am "Normin"
    When I look at one of these pages, then I can use the filter panel, but its not open initially:
    | page_type              |
    | my media entries       |
    | my sets page           |
    | my favorites           |
    | content assigned to me |
    | public content         |
    | set view               |
    When I look at one of these pages, then the filter panel is already expanded:
    | search results         |

  @javascript
  Scenario: Filtering by MetaDatumKeywords
   Given I am "Normin"
    Given a list contains resources that have values in a meta key of type "Keywords"
    Then I can filter by the values for that particular key

  @javascript
  Scenario: Behavior when selecting and deselecting a filter
   Given I am "Normin"
    When I select a value to filter by
    Then I see all the values that can still be used as additional filters
     And all values that have no results disappear
    When I deselect the value
     Then all previously disappeared values are reappearing

  @javascript
  Scenario: Behavior when collapsing a context or a key
   Given I am "Normin"
    When I select a value to filter by
     And I collapse its parent key
    Then all selected nested terms do not disappear 
     And I collapse its parent context
    Then all selected nested terms do not disappear 

  @javascript
  Scenario: Rules for when a MetaKey is displayed in the filter panel
   Given I am "Normin"
    Given a list of resources
    When I see the filter panel
    Then I see a list of MetaKeys the resources have values for

  @javascript
  Scenario: Result counts for each value
   Given I am "Normin"
    Given I see a filtered list of resources
    Then I see the match count for each value whose filter type is "meta_data" and the values are sorted by match counts
    And I do not see the match count for each value whose filter type is "permissions"
    And I do not see the match count for each value whose filter type is "media_file"

  @javascript
  Scenario: Filtering contents of a set that has many things in it
   Given I am "Liselotte"
    When I open a set that has children
    Then I can expand the filter panel
    And I see a list of MetaKeys
    And I can open a particular MetaKey
    And I can filter by the values of that key

  @javascript
  Scenario: MetaContexts in the filter panel
   Given I am "Normin"
    Given I see a list of resources that can be filtered
    And some of the keys with the filter type "meta_data" are in any contexts
    Then I can expand the context to reveal the keys

  # https://www.pivotaltracker.com/story/show/36230221
  @javascript
  Scenario: Selecting keys that appear in multiple MetaContexts in the filter panel
   Given I am "Normin"
    Given I see a list of resources that can be filtered
    And I select a term that is present in multiple context
    Then the term is selected in all the contexts
    When I deselect that term
    Then it is deselected in all the contexts

  # https://www.pivotaltracker.com/story/show/36222567
  @javascript
  Scenario: Feature by "any value for this key"
    Given I am "Adam"
    And I see a filtered list of resources
    When I expand a context block
    Then that block contains the value "any"
    When I filter by the value "any"
    Then I filter by all media resources that contain any value for that key

  @javascript
  Scenario: Reset filters
   Given I am "Normin"
    Given I see a filtered list of resources
     When I reset the filter panel
     Then the list is not filtered anymore

  # Was never committed
  # https://www.pivotaltracker.com/story/show/36230629
  #@javascript
  #  Scenario: Filtering by permissions
  #  Given I see a filtered list of resources
  #  And all of the blocks with the filter type "permissions" are in the root block "Permissions"
  #  When I expand the "Permissions" root block
  #  Then I can filter by user permissions, group permissions, permission presets
  #  When I select some of the permission filters
  #  Then the others are still available
  #  And the result is a union of all the selected permission filters

  @javascript
  Scenario: Filtering by media type
    Given a list of resources
    And I am "Normin"
    When I see the filter panel
    And the list contains images
    When I expand the root block "media_files"
    And I expand the sub-block "media_type" of the root block "media_files"
    Then I can filter letting me choose "image" in the sub-block "media_type" of the root block "media_files"

  @javascript 
  Scenario: Filtering by file extension
    Given I am "Normin"
    Given a list of resources
    When I see the filter panel
    And the list contains images
    When I expand the root block "media_files"
    And I expand the sub-block "extension" of the root block "media_files"
    Then I can filter letting me choose "jpg" in the sub-block "extension" of the root block "media_files"

  @javascript 
  Scenario: Filtering empty values
    Given I am "Karen"
    Given a list of resources
    When I see the filter panel
    And the filter panel contains empty values
    Then the label text of the empty values is "unbekannt"

  # Was never committed
  #@javascript
  #Scenario: Criteria of the filter panel
  #  Given a list contains resources that have values in a meta key of type "MetaTerms"
  #  Then I can filter by the values for that particular key
  #  #Given a list contains resources that have values in a meta key of type "MetaDepartments"
  #  #Then I can filter by the values for that particular key
  #  #And I can always filter by permissions that appear in the result set
  #  And I can always filter by image formats that appear in the result set
  #  #And I can always filter by owners that appear in the result set
  #  #And I can always filter by groups that appear in the result set
