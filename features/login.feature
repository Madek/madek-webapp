Feature: Login

  @clean
  Scenario: Login with ZHdK auth
    When I go to the home page
    And I click on the ZHdK-Login
    Then There is a link to the "/login" path

  @clean
  Scenario: Login with database authentication
    When I go to the home page
    When I click on the database login tab
    And I set the input with the name "login" to "Normin"
    And I set the input with the name "password" to "password"
    And I click the submit button
    Then I am logged in


