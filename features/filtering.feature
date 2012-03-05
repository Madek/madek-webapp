Feature: Use the search filters on my search results

  After searching for some keyword, I want to filter my results so that I find media that
  more accurately matches what I'm looking for.

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Evil Librarian" with username "evil" and password "books" exists

  @javascript 
  Scenario: A simple search, no filtering, that should return a result
    When I log in as "evil" with password "books"
     And I upload some picture titled "The Necronomicon"
     And I fill in "query" with "necronomicon"
     And I press "Suchen"
    Then I should see "The Necronomicon"
    When I fill in "query" with "cute kittens"
     And I press "Suchen"
    Then I should not see "The Necronomicon"


 # We had a problem with this earlier, this is to prevent a regression.
 # The error was that users were logged out when pressing "Filter anwenden" without
 # selecting any options.
 @javascript @foofoo
  Scenario: Searching without parameters should not raise an error
    When I log in as "evil" with password "books"
     And I upload some picture titled "Random Nonsense"
     And I fill in "query" with "nonsense"
     And I press "Suchen"
    Then I should see "Random Nonsense"
    When I press "Filter anwenden"
     And I wait for 2 seconds
    Then I should not see "Bitte anmelden"
     And I should see "Suchergebnisse"

  @javascript
  Scenario: Filtering by keyword: Finding both media entries that have a common word, but showing just one when only one's keyword is selected
    When I log in as "evil" with password "books"
     And I upload some picture titled "The Necronomicon"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "The Necronomicon"
     And I fill in the metadata form as follows:
     |label                          |value|
     |Schlagworte zu Inhalt und Motiv|evil|
     |Schlagworte zu Inhalt und Motiv|book|
     |Schlagworte zu Inhalt und Motiv|common words|
     |Schlagworte zu Inhalt und Motiv|necro|
     |Schlagworte zu Inhalt und Motiv|raimi|
     |Schlagworte zu Inhalt und Motiv|dead|
     And I press "Speichern"

     And I upload some picture titled "Klaatu Barata Nicto"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Klaatu Barata Nicto"
     And I fill in the metadata form as follows:
     |label                          |value|
     |Schlagworte zu Inhalt und Motiv|evil|
     |Schlagworte zu Inhalt und Motiv|nasty|
     |Schlagworte zu Inhalt und Motiv|curse|
     |Schlagworte zu Inhalt und Motiv|common words|
     |Schlagworte zu Inhalt und Motiv|raimi|
     And I press "Speichern"
     And I fill in "query" with "common"
     And I press "Suchen"
    Then the search results should contain "The Necronomicon"
     And the search results should contain "Klaatu Barata Nicto"
     When I filter by "nasty" in "Schlagworte"
     And I press "Filter anwenden"
     And I wait for 4 seconds
    Then the search results should not contain "The Necronomicon"
     And the search results should contain "Klaatu Barata Nicto"

  @javascript
  Scenario: Filtering three different media entries
    When I log in as "evil" with password "books"
     And I upload some picture titled "Pure Evil"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Pure Evil"
     And I fill in the metadata form as follows:
     |label                          |value|
     |Schlagworte zu Inhalt und Motiv|evil|
     |Schlagworte zu Inhalt und Motiv|book|
     |Schlagworte zu Inhalt und Motiv|common words|
     |Schlagworte zu Inhalt und Motiv|pure|
     And I press "Speichern"
     And I upload some picture titled "Slightly less pure evil"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Slightly less pure evil"
     And I fill in the metadata form as follows:
     |label                          |value|
     |Schlagworte zu Inhalt und Motiv|unpure|
     |Schlagworte zu Inhalt und Motiv|not too evil|
     |Schlagworte zu Inhalt und Motiv|common words|
     |Schlagworte zu Inhalt und Motiv|evil|
     And I press "Speichern"
     And I upload some picture titled "Completely unpure evil"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Completely unpure evil"
     And I fill in the metadata form as follows:
     |label                          |value|
     |Schlagworte zu Inhalt und Motiv|good|
     |Schlagworte zu Inhalt und Motiv|not bad|
     |Schlagworte zu Inhalt und Motiv|common words|
     And I press "Speichern"
     And I fill in "query" with "evil"
     And I press "Suchen"
    Then the search results should contain "Pure Evil"
     And the search results should contain "Slightly less pure evil"
     And the search results should contain "Completely unpure evil"
     And I wait for 16 seconds
    When I filter by "evil" in "Schlagworte"
     And I press "Filter anwenden"
    Then the search results should contain "Pure Evil"
     And the search results should contain "Slightly less pure evil"
     And the search results should not contain "Completely unpure evil"
    When I fill in "query" with ""
     And I fill in "query" with "evil"
     And I press "Suchen"
    Then the search results should contain "Pure Evil"
     And I wait for 16 seconds

    When I filter by "unpure" in "Schlagworte"
     And I press "Filter anwenden"
     And I wait for 2 seconds
    Then the search results should not contain "Pure Evil"
     And the search results should contain "Slightly less pure evil"
     And the search results should not contain "Completely unpure evil"
    When I fill in "query" with ""
     And I fill in "query" with "evil"
     And I press "Suchen"
    Then the search results should contain "Pure Evil"
     And I wait for 16 seconds
    When I filter by "good" in "Schlagworte"
     And I press "Filter anwenden"
     And I wait for 2 seconds
    Then the search results should not contain "Pure Evil"
     And the search results should not contain "Slightly less pure evil"
     And the search results should contain "Completely unpure evil"
