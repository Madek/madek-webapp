Feature: Importing files with metadata and setting metadata 

    @chrome 
    Scenario: Using the sequential metadata editor
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "berlin_wall_01.jpg"
    And I attach the file "berlin_wall_02.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 01" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Nächster Eintrag"
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 02" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "2" new media_entries
    And there is a entry with the title "Berlin Wall 01" in the new media_entries
    And there is a entry with the title "Berlin Wall 02" in the new media_entries


  @chrome 
  Scenario: Filtering entries with missing metadata in the sequential metadata editor
    Given I am signed-in as "Normin"
    And I am going to import images

    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "berlin_wall_01.jpg"
    And I attach the file "berlin_wall_02.jpg"
    And I attach the file "date_should_be_1990.jpg"
    And I attach the file "date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 

    And I wait until I am on the "/import/meta_data" page
    Then two files with missing metadata are marked
    When I choose to list only files with missing metadata
    Then Only the files with missing metadata are listed
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 01" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Nächster Eintrag"
    And I set the input in the fieldset with "title" as meta-key to "Berlin Wall 02" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    Then there are "4" new media_entries
    And there is a entry with the title "Berlin Wall 01" in the new media_entries
    And there is a entry with the title "Berlin Wall 02" in the new media_entries

  @chrome 
  Scenario: import an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "date_should_be_2011-05-30.jpg"
    When I click on the link "Weiter"
    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 
    And I wait until I am on the "/import/meta_data" page
    And I click on the link "Weiter…" 
    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"
    Then there are "1" new media_entries
    When I visit the page of the last added media_entry
    Then I can see the text "30.05.2011"
    And I can see the text "Grumpy Cat"


  @chrome 
  Scenario: import an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "date_should_be_from_to_may.jpg"
    When I click on the link "Weiter"
    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 
    And I wait until I am on the "/import/meta_data" page
    And I click on the link "Weiter…" 
    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"
    Then there are "1" new media_entries
    When I visit the page of the last added media_entry
    Then I can see the text "01.05.2011 - 31.05.2011"
     And I can see the text "Frau-Sein"
     And I can see the text "Buser, Monika"
     And I can see the text "Diplomarbeit"
     And I can see the text "Porträt"
     And I can see the text "Selbstporträt"
     And I can see the text "Schweiz"

  @chrome 
  Scenario: import an image that has MAdeK title and date information (specific date) in its EXIF/IPTC metadata
    Given I am signed-in as "Normin"
    And I am going to import images
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    When I attach the file "date_should_be_1990.jpg"
    When I click on the link "Weiter"
    And I wait until I am on the "/import/permissions" page
    And I click on the button "Berechtigungen speichern" 
    And I wait until I am on the "/import/meta_data" page
    And I click on the link "Weiter…" 
    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"
    Then there are "1" new media_entries
    When I visit the page of the last added media_entry
    Then I can see the text "1990"
     And I can see the text "Frau-Sein"
     And I can see the text "Buser, Monika"
     And I can see the text "Frau-Sein"
     And I can see the text "Buser, Monika"
     And I can see the text "Diplomarbeit"
     And I can see the text "Porträt"
     And I can see the text "Selbstporträt"
     And I can see the text "Schweiz"




