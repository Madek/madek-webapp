Feature: Catalog

	@javascript
	Scenario: Configuring the catalog
		Given I am "Adam"
		When I select a set to be the catalog
		Then it is set as catalog for this Madek instance

	@javascript
	Scenario: Where catalog are displayed
		Given I am on the dashboard
		Then I see the content of the set that is defined as the catalog

  @javascript
	Scenario: What a catalog contains
		Given I am viewing the catalog
		Then I see the categories of that catalog
		And the categories are filter sets

  @javascript
	Scenario: Viewing a catalog
		Given I am viewing the catalog
		Then I see the title of the catalog: "Katalog"
	  And I see the description of the catalog
		And I see the children of the catalog, which are called categories
		And I see the title and description of each of these categories
		And I can choose to navigate to one of these categories

  @javascript
	Scenario: Viewing a category
		Given I am viewing the category called "Gattung"
		Then I see the title of that category: "Gattung"
		And I see the description of that category
		And I see the sections of the category "Gattung"
		And one of these sections is called "Architektur"
		And I see how many resources are related to that section
	  And this page's title is the title of the category itself, prefixed by catalog title
		And I can choose to navigate to one of these sections

	@javascript
	Scenario: Viewing a section
		Given I am viewing a section
		Then it looks and behaves mostly like a search result page filtered according to the section's filter settings
		And unlike the search result page, this page's title is the name of the section itself prefixed by catalog title and category title
