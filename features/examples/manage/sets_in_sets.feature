Feature: Sets in Sets

  Background: Set up the world with a user and logging in
    Given I have set up the world a little
      And a user called "Max" with username "max" and password "moritz" exists
      And I log in as "max" with password "moritz"
      And I am logged in as "max"

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
      And I can remove all of them from one set

