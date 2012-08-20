Feature: Advanced metadata editing features (keywords, people, controlled vocabularies...)

  Foo

  @javascript @slow
  Scenario: Changing the core text fields of a media entry
    Given I am "normin"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Millenium Falcon, Front View"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel des Werks|My beautiful and proud ship|
     |Untertitel|The Millenium Falcon|
     |Bildlegende|Foreground: A Millenium Falcon. Background: Chewbacca.|
     |Gattung|Design|
     |Gattung|Fotografie|
     And I follow "Medium"
     And I wait for the CSS element "#media_object"
     And I fill in the metadata form as follows:
     |label|value|
     |Weitere Personen Medienerstellung|Rebel United Photo Developers|
     |Material/Format|Collage|
     And I follow "Credits"
     And I wait for the CSS element "#copyright"
     And I fill in the metadata form as follows:
     |label|value|
     |Rechte|(C) 4233 Han Solo|
     And I follow "ZHdK" within ".tabs"
     And I wait for the CSS element "#zhdk_bereich"
     And I fill in the metadata form as follows:
     |label|value|
     |Projekttitel|Photographs of Han's rides|
# Testing this widget is too hard to do right now, let's skip using it.
#     |Bereich ZHdK|Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)|
     And I press "Speichern"
    Then I should not see "Millenium Falcon, Front View"
     And I should see "The Millenium Falcon"
     And I should see "Foreground: A Millenium Falcon. Background: Chewbacca."
     And I should see "Collage"
     And I should see "Photographs of Han's rides"

  @javascript @slow
  Scenario: Changing the author field on a media entry using the firstname/lastname entry form tab
    Given I am "normin"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value   |
     |Autor/in|Foo, Bar|
     And I press "Speichern"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And I click the media entry titled "Me and Leia Organa"
     And I wait for the CSS element "#detail-excerpt"
     Then I should see "Foo, Bar"

  @javascript @slow
  Scenario: Putting a pseudonym into the author field
    Given I am "normin"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value      |options           |
     |Autor/in|Yoda       |pseudonym field|
     And I press "Speichern"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And I click the media entry titled "Me and Leia Organa"
     And I wait for the CSS element "#detail-excerpt"
     Then I should see "(Yoda)"

  @javascript @slow
  Scenario: Putting a group into the group name field in the group tab
    Given I am "normin"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value             |options  |
     |Autor/in|The Rebel Alliance|group tab|
     And I press "Speichern"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And I click the media entry titled "Me and Leia Organa"
     And I wait for the CSS element "#detail-excerpt"
     Then I should see "The Rebel Alliance"

  @javascript @slow
  Scenario: Putting a name directly into the name input box
    Given I am "normin"
     And I upload some picture titled "Me and Leia Organa"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Me and Leia Organa"
     And I fill in the metadata form as follows:
     |label   |value             |options  |
     |Autor/in|Furter, Frank|in-field entry box|
     And I press "Speichern"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And I click the media entry titled "Me and Leia Organa"
     And I wait for the CSS element "#detail-excerpt"
     Then I should see "Furter, Frank"


  @javascript @slow
  Scenario: Enter some keywords into the JS-based keyword dialog box
    Given I am "normin"
     And I upload some picture titled "Me and Leia Organa on the beach"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Me and Leia Organa on the beach"
     And I fill in the metadata form as follows:
     |label   |value             |
     |Schlagworte zu Inhalt und Motiv|leia|
     |Schlagworte zu Inhalt und Motiv|beach|
     |Schlagworte zu Inhalt und Motiv|sun|
     |Schlagworte zu Inhalt und Motiv|fun|
     And I press "Speichern"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And I click the media entry titled "Me and Leia Organa on the beach"
     And I wait for the CSS element "#detail-excerpt"
     Then I should see "leia, beach, sun, fun"


  @javascript @slow
  Scenario: Using the MAdeK multi-select widget
    Given I am "normin"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I click the arrow next to my name
     And I follow "Meine Medien"
     And all the hidden items become visible
     And I switch to the grid view
     And I click the edit icon on the media entry titled "Millenium Falcon, Front View"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|My great ship|
     And I follow "ZHdK" within ".tabs"
# Testing this widget is too hard to do right now, let's skip using it.
#     And I fill in the metadata form as follows:
#     |label|value|
#     |Bereich ZHdK|Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)|
     And I press "Speichern"
    Then I should see "My great ship"
     And I should not see "Millenium Falcon, Front View"   
#     And I should see "Services, Informations-Technologie-Zentrum (SER_SUP_ITZ.alle)"
