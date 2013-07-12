Feature: Guests / Not logged in user

  @clean
  Scenario: Erkunden
    When I go to the home page
    When I click on the link "Erkunden"
    Then I am on the "/explore" page
    And I can see the text "Erkunden"


  @jsbrowser @clean
  Scenario: Search page
    When I go to the home page
    When I click on the link "Suche"
    Then I am on the "/search" page
    And I can see the text "Suche"
    And I set the input with the name "search" to "Landschaft"
    And I submit
    Then I am on the "/search/Landschaft" page
    And I can see the text "Suchresultat"
    And I can see several images 

  @clean
  Scenario: External help page
    When I go to the home page
    Then There is a link with the id "to-help"
   
  @jsbrowser @clean
  Scenario: All resources I do see have public view permission
    When I visit the "/media_resources" path
    And I can see several resources
    And All resources that I can see have public view permission

