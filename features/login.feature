Feature: Login

  @jsbrowser @clean
  Scenario: Login with ZHdK authentication
    When I go to the home page
    And I click on the ZHdK-Login
    Then I go to the ZHdK-Login page

  @clean
  Scenario: Login with database authentication
    When I go to the home page
    When I click on the database login tab
    And I set the input with the name "login" to "Normin"
    And I set the input with the name "password" to "password"
    And I click the submit button
    Then I am logged in


