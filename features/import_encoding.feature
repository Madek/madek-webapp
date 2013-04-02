Feature: encoding videos


  # Scenarios with the tag @encoding must be rung from the encoding profile, e.g: 
  #
  #   bundle exec cucumber -p encoding
  #
  # These tests run against the test server. The corresponding user
  # with the password 'password' must exist.

  @encoding @chrome
  Scenario: Importing, encoding and watching a video file
    Given I am signed-in as "Testicus"
    And I accept the usage terms if I am supposed to do so
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    And I remove all uploaded files

    When I attach the file "zencoder_test.mov"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I scroll all the way down and click on "Berechtigungen speichern"

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Zencoder Movie" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    And I wait until I am on the "/my" page
    And I click on my first media entry
    And I wait and reload while the video is converting
    Then I can not see any alert 
    And I can see the preview
    And I can watch the video


  @encoding @chrome
  Scenario: Importing and encoding a broken video file
    Given I am signed-in as "Testicus"
    And I accept the usage terms if I am supposed to do so
    And I click on the link "Medien importieren"
    Then I am on the "/import" page
    And I remove all uploaded files

    When I attach the file "files/video_with_nonexisting_reference.mov"
    When I click on the link "Weiter"

    And I wait until I am on the "/import/permissions" page
    And I scroll all the way down and click on "Berechtigungen speichern"

    And I wait until I am on the "/import/meta_data" page
    And I set the input in the fieldset with "title" as meta-key to "Broken Reference Movie" 
    And I set the input in the fieldset with "copyright notice" as meta-key to "WTFPL" 
    And I click on the link "Weiter…" 

    And I wait until I am on the "/import/organize" page
    And I click on the button "Import abschliessen"

    And I wait until I am on the "/my" page
    And I click on my first media entry
    And I wait and reload while the video is converting

    Then I see the error-alert "Konvertierung fehlgeschlagen."
    And I can see "The input file is a Quicktime file that contains external references."



