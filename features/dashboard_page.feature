Feature: Dashboard

  Scenario: The blocks of content available on the dashboard
    Given I am signed-in as "Normin"

    Given I am on the dashboard
    Then I see a block of resources showing my content
    And There is a link to my resources
    When I follow the link to my resources
    Then I am on the my resources page

    Given I am on the dashboard
    Then I see a block of resources showing my last imports

    Given I am on the dashboard
    Then I see a block of resources showing my favorites
    And There is a link to my favorites
    When I follow the link to my favorites page
    Then I am on the my favorites

    Given I am on the dashboard
    Then I see a block of my keywords
    And There is a link to my keywords
    When I follow the link to my keywords
    Then I am on the my keywords page

    Given I am on the dashboard
    Then I see a block of resources showing content assigned to me
    And There is a link to content assigned to me
    When I follow the link to content assigned to me
    Then I am on the content assigned to me page

    Given I am on the dashboard
    Then I see a list of my groups
    And There is a link to my groups
    # to be implemented
    When I follow the link to my groups
    Then I am on the my groups page

    # to be implemented
    Given I am on the dashboard
    Then I see a list of contexts which is non empty
    When I can choose to continue to the context "to be added"
    Then I see a sidebar that lists all blocks of resources showing my content
    And I can choose one of the labels
    And I got to the related page
    And I see the clipboard
    And I see context related actions
