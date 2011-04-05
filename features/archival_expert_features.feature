Feature: Exporting for archival experts and using the associated archival expert interface

  Foo

  Background: Set up the world and some users
    Given I have set up the world
      And a user called "Fred Astaire" with username "fred" and password "tapping" exists
      And a user called "Ginger Rogers" with username "ginger" and password "dancing" exists
      And a group called "MIZ-Archiv" exists
      And the user with username "fred" is member of the group "MIZ-Archiv"
      And the user with username "ginger" is member of the group "MIZ-Archiv"


  Scenario: Enter archival metadata for a media entry
    Given I log in as "fred" with password "tapping"
      And I upload some picture titled "Tapping for the Archives"
      And I go to the home page
      And I click the media entry titled "Tapping for the Archives"
      # TODO: enter archival metadata