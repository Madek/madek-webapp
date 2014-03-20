Feature: Login

  Scenario: Login with ZHdK auth
    When I go to the home page
    And I click on the ZHdK-Login
    Then There is a link to the "/login" path

  Scenario: Login with database authentication
    When I go to the home page
    When I click on the database login tab
    And I set the input with the name "login" to "Normin"
    And I set the input with the name "password" to "password"
    And I click the submit button
    Then I am logged in

  Scenario: Accepting usage terms after fresh login
    Given "Normin" has not yet accepted the usage terms
    And I am signed-in as "Normin"
    When I see a "Nutzungsbedingungen" modal
    And I click the submit button
    Then I am redirected to the media archive

  Scenario: Rejecting usage terms after fresh login
    Given "Normin" has not yet accepted the usage terms
    And I am signed-in as "Normin"
    When I see a "Nutzungsbedingungen" modal
    And I click the "Ablehnen" link
    Then I am redirected to the home page
    And I see an error alert mentioning "Nutzungsbedingungen"
