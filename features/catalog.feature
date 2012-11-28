Feature: Catalog

  Background: Load the example data and personas
    Given I am "Adam"

  @poltergeist
  Scenario: Configuring the catalog
    When I select a set to be the catalog
    Then it is set as catalog for this Madek instance

  @poltergeist
  Scenario: Where catalog are displayed
    Given I am on the dashboard
    Then I see the content of the set that is defined as the catalog

  @poltergeist
  Scenario: What a catalog contains
    Given I am viewing the catalog
    Then I see the categories of that catalog
    And the categories are filter sets

  @poltergeist
  Scenario: Viewing a catalog
    Given I am viewing the catalog
    Then I see the title of the catalog: "Katalog"
    And I see the description of the catalog
    And I see the children of the catalog, which are called categories
    And I see the title and description of each of these categories
    And I can choose to navigate to one of these categories

  @poltergeist
  Scenario: Viewing a category
    Given I am viewing the category called "Schlagworte"
    Then I see the title of that category: "Schlagworte"
    And I see the description of that category
    And I see the sections of the category "Schlagworte"
    And one of these sections is called "Fotografie"
    And I see how many resources are related to that section
    And this page's title is the title of the category itself, prefixed by catalog title
    And I can choose to navigate to one of these sections

  @poltergeist
  Scenario: Viewing a section
    Given I am viewing a section
    Then it looks and behaves mostly like a search result page filtered according to the section's filter settings
    And unlike the search result page, this page's title is the name of the section itself prefixed by catalog title and category title
