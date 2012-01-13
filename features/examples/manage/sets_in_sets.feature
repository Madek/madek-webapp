Feature: Sets in Sets

  Background: To be defined

  # We should do this when we attack the rest of the technical debt, do optimization
  Scenario: The sets in sets tool loads quickly enough
    When I open the sets in sets tool
    Then the tool loads in less than 2 seconds

  # https://www.pivotaltracker.com/story/show/22464659
  # Pts: ?
  # We don't think this should be implemented as suggested -- discuss
  # Includes implementing this through the API
  Scenario: Choosing which contexts are valid for a set
    Given a context called "Landschaftsvisualisierung"
      And a context called "Zett"
      And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
      And a set called "Zett" that has the context "Zett"
      And a set called "Zett über Landschaften" which is child of "Landschaften" and "Zett"
      And I can edit the set "Zett über Landschaften"
     When I view the set "Zett über Landschaften"
     Then I see the available contexts "Landschaftsvisualisierung" and "Zett"
     When I assign the context "Zett" to the set "Zett über Landschaften"
     Then the set "Zett über Landschaften" has the context "Zett"
     When I assign the context "Landschaftsvisualisierung" to the set "Zett über Landschaften"
     Then the set "Zett über Landschaften" has the context "Landschaftsvisualisierung"
      And the set still has its other contexts as well

  # https://www.pivotaltracker.com/story/show/22464659
  # Pts: ?
  # To discuss
  Scenario: Viewing which contexts a set could have
    Given a context called "Landschaftsvisualisierung"
      And a context called "Zett"
      And a context called "Games"
      And a set called "Landschaften" that has the context "Landschaftsvisualisierung"
      And a set called "Zett" that has the context "Zett"
      And a set called "Zett über Landschaften" which is child of "Landschaften" and "Zett"
     When I view the set "Zett über Landschaften"
     Then I can choose to see more details about the context "Zett"
      And I can choose to see more details about the context "Landschaftsvisualisierung"
      And I can choose to see more details about the context "Games"

  # https://www.pivotaltracker.com/story/show/12828561
  # Pts: 40 - ?
  # Cannot be solved before we attack this: https://www.pivotaltracker.com/story/show/21437563
  # This includes refactoring of media sets/entries -> resources
  Scenario: Add a set to my favorites
   Given I see some sets
    When I add them to my favorites
    Then they are in my favorites

  # https://www.pivotaltracker.com/story/show/22779469
  # Pts: 3
  #
  # Formerly:
  #  Das Widget "zu Set hinzufügen" hat mehrere tolle Funktionen. Diese sind sehr gedrängt auf einem kleinen Feld untergebracht. Das Widget soll übersichtlicher gestaltet werden. Siehe Screenshot
  #Ziel:
  #- User kann die Namen der Sets besser lesen
  #- User kann lesen, wer der Owner des Sets ist (wie im Alten Widget)
  #- User wundert sich nicht über die rosarote Farbe: Widget soll nicht rosarot sein
  #- Die Angewählten Sets sollen grau hinterlegt sein und die Anzeige des Rollovers. Anstatt wie jetzt, wo alles grau ist und die Angezeigten / Rollovers weiss werden
  #- Die Funktion "Neues Set erstellen" soll als Button gestaltet werden.
  #- User kann nach eigenen Sets filtern durch ein Häkchen im Kopf des Widgets (Meine Sets)
  #- das Flyout über dem Icon soll lauten: "zu Set hinzufügen bzw. daraus entfernen"
  #- das Widget erscheint schnell nachdem man den Button angewählt hat
  #
  # Currently:
  @current
  Scenario: Information I see when I open the sets in sets tool
     When I open the sets in sets tool
      And I see all sets I can edit
      # And I can filter for my sets # The "my" is not defined yet!
      And I can see the owner of each set
      And I can see that selected sets are already highlighted
      And I can choose to see additional information
      And I can read the first 30 characters of each set name
      # And I can see enough information to differentiate between similar sets # Ask SUS: What makes it possible to differentiate similar sets?

  # https://www.pivotaltracker.com/story/show/22421449
  # Pts: 13
  @current
  Scenario: Moving resources into or out of multiple sets at the same time
    Given multiple resources are in my selection
      And they are in various different sets
     When I open the sets in sets tool
     Then I see the sets none of them are in
      And I see the sets some of them are in
      And I see the sets all of them are in
      And I can add all of them to one set
      And I can remove all of them from one set

  # https://www.pivotaltracker.com/story/show/22576523
  # Pts: 20
  # Includes refactoring the view, moving to the API
  @current
  Scenario: Viewing a context
    Given a context
     When I look at a page describing this context
     Then I see all the keys that can be used in this context
      And I see all the values those keys can have
      And I see an abstract of the most assigned values from media entries using this context

