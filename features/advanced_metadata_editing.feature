Feature: Advanced metadata editing features (keywords, people, controlled vocabularies...)

  Foo

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Han Solo" with username "hansolo" and password "leia" exists
      And a user called "Obi-Wan Kenobi" with username "obi" and password "sabers" exists
      And a user called "Lando Calrissian" with username "lando" and password "bounty" exists

  @javascript @work
  Scenario: Changing the core text fields of a media entry
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Millenium Falcon, Front View"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|My Beautiful and proud ship|
     |Untertitel|The Millenium Falcon|
     |Bildlegende|Foreground: A Millenium Falcon. Background: Chewbacca.|
     And I press "Speichern"
    Then I should see "My Beautiful and proud ship"
     And I should see "The Millenium Falcon"
     And I should see "Foreground: A Millenium Falcon. Background: Chewbacca."
     And I should not see "Millenium Falcon, Front View"