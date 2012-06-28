Feature: Exporting a file

  Foo

  Background: Set up the world and some users
    Given I have set up the world a little

  # This only verifies that we can click the button and thereby kicks some of the ZIP download code
  # into life. Because of Capybara's philosophy, we can't access the response object and so we can't
  # find out if the download really works. This should be done in rspec or unit tests instead.
  # We can't use Webrat instead of Capybara because we are 100% dependent on browser-like JavaScript support.
  @javascript
  Scenario: Exporting a file as ZIP with metadata
    Given I am "normin"
     And I upload some picture titled "Millenium Falcon, Front View"
     And I go to the home page
     And I click the media entry titled "Millenium Falcon, Front View"
     And I follow "Exportieren"
    Then I click the download button for ZIP with metadata     