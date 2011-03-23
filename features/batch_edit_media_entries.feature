Feature: Batch edit media entries

  Foo

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Helmut Kohl" with username "helmi" and password "schweinsmagen" exists
     When I log in as "helmi" with password "schweinsmagen"
      And I upload some picture titled "Picture One"
      And I upload some picture titled "Picture Two"
      And I upload some picture titled "Picture Three"


  @javascript @work
  Scenario: Remove two media entries from a set using batch edit
    When I log in as "helmi" with password "schweinsmagen"
     And I create a set titled "Set One"
     And I add the picture "Picture One" to the set "Set One"
     And I add the picture "Picture Two" to the set "Set One"
     And I add the picture "Picture Three" to the set "Set One"
     And I go to the media entries
     And I click the media entry titled "Picture One"
     And I follow "Set One"
     And I check the media entry titled "Picture One"
     And I check the media entry titled "Picture Two"
     And I press "Aus Set entfernen"
     And I go to the media entries
     And I click the media entry titled "Picture Three"
     And I follow "Set One"
    Then I should not see "Picture One"
     And I should not see "Picture Two"


