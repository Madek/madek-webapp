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

  @javascript 
  Scenario: Filtering by keyword
    When I log in as "evil" with password "books"
     And I upload some picture titled "The Necronomicon"
     And I click the arrow next to "Librarian, Evil"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "The Necronomicon"
     And I fill in the metadata form as follows:
     |label   |value             |
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
     |label   |value             |
     |Schlagworte zu Inhalt und Motiv|evil|
     |Schlagworte zu Inhalt und Motiv|nasty|
     |Schlagworte zu Inhalt und Motiv|curse|
     |Schlagworte zu Inhalt und Motiv|common words|
     |Schlagworte zu Inhalt und Motiv|raimi|
     And I press "Speichern"
     And I wait for 15 seconds
     And Sphinx is forced to reindex
     And I fill in "query" with "common"
     And I wait for 15 seconds
     And I press "Suchen"
    Then I should see "The Necronomicon"
     And I should see "Klaatu Barata Nicto"
    When I follow "Medieneinträge filtern"
     And I filter by "nasty" in "Schlagworte"
     And I press "Filter anwenden"
    Then I should not see "The Necronomicon"
     And I should see "Klaatu Barata Nicto"
