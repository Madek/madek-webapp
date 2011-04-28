Feature: Advanced metadata editing features (keywords, people, controlled vocabularies...)

  Foo

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Han Solo" with username "hansolo" and password "leia" exists
      And a user called "Obi-Wan Kenobi" with username "obi" and password "sabers" exists
      And a user called "Lando Calrissian" with username "lando" and password "bounty" exists

  @javascript
  Scenario: Changing the core text fields of a media entry
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Millenium Falcon, Front View"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|My beautiful and proud ship|
     |Untertitel|The Millenium Falcon|
     |Bildlegende|Foreground: A Millenium Falcon. Background: Chewbacca.|
     |Beschreibung|A lovely, lovely ship, that.|
     |Bemerkung|I never owned a better ship.|
     |Internet Links (URL)|http://www.milleniumfalcon.com|
     |Standort/Aufführungsort|Tatooine|
     |Mitwirkende / weitere Personen|Obi-Wan Kenobi|
     |Porträtierte Person/en|Chewbacca|
     |Partner / beteiligte Institutionen|Rebel Alliance|
     |Auftrag durch|No one! I am my own boss.|
     |Gattung|Design|
     |Gattung|Fotografie|
     And I follow "Medium"
     And I wait for 3 seconds
     And I fill in the metadata form as follows:
     |label|value|
     |Weitere Personen Medienerstellung|Rebel United Photo Developers|
     |Dimensionen|2380x1200px|
     |Material/Format|Holo-Recording|
     And I follow "Credits"
     And I wait for 3 seconds
     And I fill in the metadata form as follows:
     |label|value|
     |Copyright|(C) 4233 Han Solo|
     |Quelle|My own digital camera|
     |Angeboten durch|Rebel Photography Syndicate|
     And I follow "ZHdK" within ".tabs"
     And I wait for 3 seconds
     And I fill in the metadata form as follows:
     |label|value|
     |Projekttitel|Photographs of Han's rides|
     |Dozierende/Projektleitung|No one teaches me!|
     |Bereich ZHdK|Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)|
     And I press "Speichern"
    Then I should see "My beautiful and proud ship"
     And I should not see "Millenium Falcon, Front View"
     And I should see "The Millenium Falcon"
     And I should see "Foreground: A Millenium Falcon. Background: Chewbacca."
    When I follow "Medium"
     And I wait for 2 seconds
     And I wait for the CSS element ".ui-tabs-panel"
    Then I should see "Rebel United Photo Developers"
     And I should see "Holo-Recording"
    When I follow "Credits" within ".ui-tabs-nav"
     And I wait for 2 seconds
     And I wait for the CSS element ".ui-tabs-panel"
    Then I should see "Rebel Photography Syndicate"
     And I should see "My own digital camera"
    When I follow "ZHdK" within ".ui-tabs-nav"
     And I wait for 2 seconds
     And I wait for the CSS element ".ui-tabs-panel"
    Then I should see "No one teaches me!"
     And I should see "Photographs of Han's rides"

  @javascript
  Scenario: Changing the author field on a media entry using the firstname/lastname entry form tab
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value      |
     |Autor/in|Foo, Bar   |
     And I press "Speichern"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And I wait for 3 seconds
     And I click the media entry titled "Me and Leia Organa"
     Then I should see "Foo, Bar"

  @javascript
  Scenario: Putting a pseudonym into the author field
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value      |options           |
     |Autor/in|Yoda       |pseudonym field|
     And I press "Speichern"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And I wait for 3 seconds
     And I click the media entry titled "Me and Leia Organa"
     And I wait for 3 seconds
     Then I should see "(Yoda)"

  @javascript
  Scenario: Putting a group into the group name field in the group tab
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value             |options  |
     |Autor/in|The Rebel Alliance|group tab|
     And I press "Speichern"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And I wait for 3 seconds
     And I click the media entry titled "Me and Leia Organa"
     And I wait for 3 seconds
     Then I should see "The Rebel Alliance"

  @javascript
  Scenario: Putting a name directly into the name input box
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value             |options  |
     |Autor/in|Furter, Frank|in-field entry box|
     And I press "Speichern"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And I wait for 3 seconds
     And I click the media entry titled "Me and Leia Organa"
     And I wait for 3 seconds
     Then I should see "Furter, Frank"


  @javascript
  Scenario: Enter some keywords into the JS-based keyword dialog box
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Me and Leia Organa on the beach"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Me and Leia Organa on the beach"
     And I fill in the metadata form as follows:
     |label   |value             |
     |Schlagworte zu Inhalt und Motiv|leia|
     |Schlagworte zu Inhalt und Motiv|beach|
     |Schlagworte zu Inhalt und Motiv|sun|
     |Schlagworte zu Inhalt und Motiv|fun|
     And I press "Speichern"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And I wait for 3 seconds
     And I click the media entry titled "Me and Leia Organa on the beach"
     And I wait for 3 seconds
     Then I should see "leia, beach, sun, fun"


  @javascript @work
  Scenario: Using the MAdeK multi-select widget
    When I log in as "hansolo" with password "leia"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I click the arrow next to "Solo, Han"
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I click the edit icon on the media entry titled "Millenium Falcon, Front View"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|My great ship|
     And I follow "ZHdK" within ".tabs"
     And I wait for 3 seconds
     And I fill in the metadata form as follows:
     |label|value|
     |Bereich ZHdK|Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)|
     And I press "Speichern"
    Then I should see "My great ship"
     And I should not see "Millenium Falcon, Front View"
    When I follow "ZHdK" within ".ui-tabs-nav"
     And I wait for 2 seconds
     And I wait for the CSS element ".ui-tabs-panel"
    Then I should see "Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)"
