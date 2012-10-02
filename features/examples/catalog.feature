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
	Scenario: Viewing a category

	@javascript
	Scenario: Viewing a section
		Given I am viewing a section
		Then it looks and behaves exactly like a search result page filtered according to the section's terms
