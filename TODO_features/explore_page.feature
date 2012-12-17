Feature: Explore Page

  Background: Load the example data and personas
    Given personas are loaded

  @javascript
  Scenario: Elements of explore page
    When I go to the explore page
    Then I see a selection of the images of the teaser set
    And I see elements of the catalog
    And I see sets of the featured sets
    And I see new content
    And I see a sidebar
    When I logged in
    Then I see the clipboard
    When I click on show me more of the catalog
    Then I go to the catalog page
    When I click on show me more of the featured sets
    Then I go to the featured sets set page
    When I click on show me more of new content
    Then I go to the new content page
    When I click on the sidebar
    Then I go directly to the related page
  
  Scenario: 
    When I am Normin
    When I go to the explore page
    Then I see ......

