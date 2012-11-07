Feature: Filter Media Resources

  In order to filter media resources
  As a user
  I want to be to use multiple filters on a list of resources

  @javascript
  Scenario: Paginate a filtered list
   Given I am "Normin"
    When I see a filtered list of resources with more then one page
    Then I can paginate to see the following pages which are also filtered