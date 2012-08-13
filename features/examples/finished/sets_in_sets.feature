Feature: Sets in Sets

  Background: Set up the world with a user and logging in
    Given I have set up the world a little
      And a user called "Max" with username "max" and password "password" exists
      And I am "max"

  # https://www.pivotaltracker.com/story/show/12828561
  # Pts: 40 - ?
  # This includes refactoring of media sets/entries -> resources
  @javascript
  Scenario: Add a set to my favorites
   Given I see some sets
    When I add them to my favorites
    Then they are in my favorites
    And I can open them and see that are set as favorite

  # https://www.pivotaltracker.com/story/show/22779469
  # Pts: 3
  #
  # Formerly:
  #  Das Widget "zu Set hinzufügen" hat mehrere tolle Funktionen. Diese sind sehr gedrängt auf einem kleinen Feld untergebracht. Das Widget soll übersichtlicher gestaltet werden. Siehe Screenshot
  #Ziel:
  #- User kann die Namen der Sets besser lesen
  #- User kann lesen, wer der Owner des Sets ist (wie im Alten Widget)
  #- User wundert sich nicht über die rosarote Farbe: Widget soll nichttt rosarot sein
  #- Die Angewählten Sets sollen grau hinterlegt sein und die Anzeige des Rollovers. Anstatt wie jetzt, wo alles grau ist und die Angezeigten / Rollovers weiss werden
  #- Die Funktion "Neues Set erstellen" soll als Button gestaltet werden.
  #- User kann nach eigenen Sets filtern durch ein Häkchen im Kopf des Widgets (Meine Sets)
  #- das Flyout über dem Icon soll lauten: "zu Set hinzufügen bzw. daraus entfernen"
  #- das Widget erscheint schnell nachdem man den Button angewählt hat
  #
  # Not yet implemented:
  # And I can filter for my sets # The "my" is not defined yet!
  #
  # Currently:
  @javascript
  Scenario: Information I see when I open the sets in sets tool
    Given are some sets and entries
     When I open the sets in sets tool
     Then I see all sets I can edit
      And I can see the owner of each set
# broken at the moment: the set the test is creating and navigating to is NOT selected, so it's not highlighted either!
#      And I can see that selected sets are already highlighted
      And I can choose to see additional information
#      And I can read the sliced title of each set
      And I can see enough information to differentiate between similar sets

  # https://www.pivotaltracker.com/story/show/22421449
  # Pts: 13
  @javascript
  Scenario: Moving resources into or out of multiple sets at the same time
    Given some entries and sets are in my selection
      And they are in various different sets
     When I open inside the batch edit the sets in sets widget
     Then I see the sets none of them are in
      And I see the sets some of them are in
      And I see the sets all of them are in
      And I can add all of them to one set
# super-unreliable, only runs when started alone, not with other tests, but has nothing to do with the data that we have
# available. re-enable when it's reliable.
#      And I can remove all of them from one set


  @javascript
  Scenario: Upload an image, then go to the detail page and add it to a set
    When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                        |
     | Titel     | into the set after uploading |
     | Rechte | some other dude              |
     And I follow "weiter..."
     And I follow "Import abschliessen"
     And I go to the media entries
     And I wait for the CSS element "div.page div.item_box"
     And I click the media entry titled "into the set after uploading"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
    Then I see the set-box "After-Upload Set"
     And I should not see "Ohne Titel"

 @javascript
  Scenario: Rename a set
     When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value                        |
     | Titel     | into the set after uploading |
     | Rechte | some other dude              |
     And I follow "weiter..."
     And I follow "Import abschliessen"
     And I go to the media entries
     And I click the media entry titled "into the set after uploading"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
     And I click the arrow next to my name
     And I follow "Meine Sets"
     And I click the media entry titled "After-Upload Set"
     And I hover the context actions menu
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     |label|value|
     |Titel|Something new|
     And I press "Speichern" within ".save_buttons"
    Then I should see "Die Änderungen wurden gespeichert"
     And I should see "Something new"
     And I should not see "After-Upload Set"

  @javascript
  Scenario: Use a URL in a set description and expect it to turn into a link
     When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory
     And I go to the upload edit
     And I fill in the metadata for entry number 1 as follows:
     | label     | value           |
     | Titel     | Link test       |
     | Rechte | some other dude |
     And I follow "weiter..."
     And I follow "Import abschliessen"
     And I go to the media entries
     And I click the media entry titled "Link test"
     And I open the selection widget for this entry
     And I create a new set named "After-Upload Set"
     And I submit the selection widget
     And I go to the home page
    Then I should see "Link test"
    When I click the media entry titled "Link test"
     And I hover the context actions menu
     And I follow "Editieren"
     And I fill in the metadata form as follows:
     | label        | value                                       |
     | Beschreibung | Here is a wonderful link http://www.zhdk.ch |
     And I press "Speichern"
     And I expand the "Metadaten" context group
    Then I should see "http://www.zhdk.ch"
    When I follow "http://www.zhdk.ch"
     



  # https://www.pivotaltracker.com/story/show/23825307
  @javascript
  Scenario: Preview of content and relationships of a set in the grid view
    Given I am "Normin"
     When I view a grid of these sets
      And I examine my "Ausstellungen" sets more closely
     Then I see relationships for this set
      And I see how many media entries that are viewable for me in this set
      And I see how many sets that are viewable for me in this set
      And I see previews of the resources that are children of this set
      When I hover those previews of children I see the title of those resources 
      And I see how many sets that are viewable for me are parents of this set
      And I see previews of the resources that are parent of this set
      When I hover those previews of parents I see the title of those resources
      
  @javascript
  Scenario: MediaEntry popup on a media set page
    Given I am "Normin"
      And I open a set which has child media entries
      And I switch the list of the childs to the miniature view
      And I examine one of the child media entry more closely
     Then I see more information about that media entry popping up

  # https://www.pivotaltracker.com/story/show/22394303
  @javascript
  Scenario: Choosing which contexts are valid for a set
   Given I am "Adam"
     And a context called "Landschaftsvisualisierung" exists
     And a context called "Zett" exists
     And a context called "Games" exists
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" that has the context "Games"
     And the set called "Zett über Landschaften" is child of "Landschaften" and "Zett"
     And I can edit the set "Zett über Landschaften"
    When I view the set "Zett über Landschaften"
    Then I see the available contexts "Landschaftsvisualisierung" and "Zett"
     And I see some text explaining the consequences of assigning contexts to a set
    When I assign the context "Zett" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Zett"
    When I assign the context "Landschaftsvisualisierung" to the set "Zett über Landschaften"
    Then the set "Zett über Landschaften" has the context "Landschaftsvisualisierung"
     And the set still has the context called "Games"

  # https://www.pivotaltracker.com/story/show/22464659
  @javascript
  Scenario: Viewing which contexts a set could have
   Given I am "Adam"
     And a context called "Landschaftsvisualisierung" exists
     And a context called "Zett" exists
     And a context called "Games" exists
     And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
     And a set called "Zett" that has the context "Zett"
     And a set called "Zett über Landschaften" that has the context "Games"
     And the set called "Zett über Landschaften" is child of "Landschaften" and "Zett"
    When I view the set "Zett über Landschaften"
    Then I can choose to see more details about the context "Zett"
     And I can choose to see more details about the context "Landschaftsvisualisierung"
     And I can choose to see more details about the context "Games"

  # https://www.pivotaltracker.com/story/show/23825857
  # Use @persona-dump if you want to load the persona dump and use truncation even in a non-javsacript step
  @glossary
  Scenario: Top-level set
    Given a few sets
     When a set has no parents
     Then it is a top-level set