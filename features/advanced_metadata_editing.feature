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
     And I follow "Medium"
     And I fill in the metadata form as follows:
     |label|value|
     |Weitere Personen Medienerstellung|Rebel United Photo Developers|
     |Dimensionen|2380x1200px|
     |Material/Format|Holo-Recording|
     And I follow "Credits"
     And I fill in the metadata form as follows:
     |label|value|
     |Copyright|(C) 4233 Han Solo|
     |Quelle|My own digital camera|
     |Angeboten durch|Rebel Photography Syndicate|
     And I follow "ZHdK" within ".tabs"
     And I fill in the metadata form as follows:
     |label|value|
     |Projekttitel|Photographs of Han's rides|
     |Dozierende/Projektleitung|No one teaches me!|
     And I press "Speichern"
    Then I should see "My beautiful and proud ship"
     And I should not see "Millenium Falcon, Front View"
     And I should see "The Millenium Falcon"
     And I should see "Foreground: A Millenium Falcon. Background: Chewbacca."
    When I follow "Medium"
    Then I should see "Rebel United Photo Developers"
     And I should see "Holo-Recording"
#    When I follow "Credits" within ".tabs"
#    Then I should see "Rebel Photography Syndicate"
#     And I should see "My own digital camera"
    When I follow "ZHdK" within ".tabs"
    Then I should see "No one teaches me!"
     And I should see "Photographs of Han's rides"