Feature: Filter Panel

  As a MAdeK user 
  I want to filter lists of resources
  So that can narrow down results

   @jsbrowser 
  Scenario: Filter by "Säulenordnungen"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Säulenordnungen"
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count

   @jsbrowser
  Scenario: Filter by "ZHdK"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "ZHdK"
     And I click on the link "ZHdK-Projekttyp"
     And I remember the count for the filter "Abschlussarbeit"
     And I click on the link "Abschlussarbeit"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count

   @jsbrowser
  Scenario: Filter by "Lehrmittel Fotografie"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Lehrmittel Fotografie"
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count

   @jsbrowser 
  Scenario: Combining multiple filter from multiple groups: "Datei" and "Berechtigung"
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Datei"
     And I click on the link "Dokumenttyp"
     And I remember the count for the filter "jpg"
     And I click on the link "jpg"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count
     When I remember the number of resources
     And I click on the link "Berechtigung"
     When I click on the link "Verantwortliche Person"
     And I remember the count for the filter "Knacknuss, Karen"
     And I click on the link "Knacknuss, Karen"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count

   @jsbrowser 
  Scenario: Resetting all filters
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Datei"
     And I click on the link "Dokumenttyp"
     And I remember the count for the filter "jpg"
     And I click on the link "jpg"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count
     And I click on the link "Berechtigung"
     When I click on the link "Verantwortliche Person"
     And I remember the number of resources
     And I remember the count for the filter "Knacknuss, Karen"
     And I click on the link "Knacknuss, Karen"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count
     And I click on the link "Filter zurücksetzen"
     And I wait for the number of resources to change
     When I remember the number of resources
     And I go to the media_resources with filter_panel
     Then the number or resources is equal to the remembered number of resources

   @jsbrowser 
  Scenario: Resetting single filters
     Given I am signed-in as "Liselotte"
     And I go to the media_resources with filter_panel
     And I remember the number of resources
     And I click on the link "Datei"
     And I click on the link "Dokumenttyp"
     And I remember the count for the filter "jpg"
     And I click on the link "jpg"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count
     When I remember the number of resources
     And I click on the link "Landschaftsvisualisierung"
     And I click on the link "Stil- und Kunstrichtungen"
     And I remember the count for the filter "Konzeptkunst"
     And I click on the link "Konzeptkunst"
     And I wait for the number of resources to change
     Then the number or resources is equal to the remembered filter count

     When I remember the number of resources
     And I click on the link "Konzeptkunst"
     Then I wait for the number of resources to change

     When I remember the number of resources
     And I click on the link "jpg"
     Then I wait for the number of resources to change

     When I remember the number of resources
     And I go to the media_resources with filter_panel
     Then the number or resources is equal to the remembered number of resources
