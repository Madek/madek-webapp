Feature: Filter panel

  As a MAdeK user
  I want to be able to filter resources on many different pages
  So that I can get a good overview of all the things in the system
  And I can reduce my overview depending on various filter criteria

  Background: Load the example data and personas
    Given personas are loaded
      And I am "Normin"

  @javascript
  Scenario: Where the filter panel appears
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
    Given a list contains resources that have values in a meta key of type "Keywords"
    Then I can filter by the values for that particular key

  @javascript
  Scenario: Behavior when selecting a filter
    When I select a value to filter by
    Then I see all the values that can be filtered or not filtered by
    When I deselect the value
    Then none of the values are deactivated

  @javascript
  Scenario: Rules for when a MetaKey is displayed in the filter panel
    Given a list of resources
    When I see the filter panel
    Then I see a list of MetaKeys the resources have values for

  @javascript
  Scenario: Result counts for each value
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

  Scenario: MetaContexts in the filter panel
	  Given I see a filtered list of resources 
    And some of the keys with the filter type "meta_data" are in any contexts
    Then I see the context listed in the filter panel
    And I can expand the context to reveal the keys

  Scenario: Selecting keys that appear in multiple MetaContexts in the filter panel
	  Given I see a filtered list of resources 
    And some of the keys with the filter type "meta_data" are in any contexts
    And I select a key that is present in multiple context
    Then the key is selected in all the contexts
		And when I deselect that key
    Then it is deselected in all the contexts

	Scenario: Filtering by permissions
		Given I see a filtered list of resources
    And all of the blocks with the filter type "permissions" are in the root block "Permissions"
    When I expand the "Permissions" root block
		Then I can filter by user permissions, group permissions, permission presets
	  When I select some of the permission filters
    Then the others are still available
		And the result is a union of all the selected permission filters

  Scenario: Filtering by media file properties
    Given I see a filtered list of resources
    And the list contains images
    When I expand the root block "File Properties"
    And I expand the block "Image Properties"
    Then I can filter by the width of the image (exactly, less than, greater than)
    And I can filter by the height of the image (exactly, less than, greater than)
    And I can filter by landscape orientation
    And I can filter by portrait orientation
    
  #@upcoming
  #Scenario: Criteria of the filter panel
    #Given a list contains resources that have values in a meta key of type "MetaTerms"
    #Then I can filter by the values for that particular key
    #Given a list contains resources that have values in a meta key of type "MetaDepartments"
    #Then I can filter by the values for that particular key
    #And I can always filter by permissions that appear in the result set
    #And I can always filter by image formats that appear in the result set
    #And I can always filter by owners that appear in the result set
    #And I can always filter by groups that appear in the result set

	#@upcoming
	#Scenario: Filtering by individual contexts
