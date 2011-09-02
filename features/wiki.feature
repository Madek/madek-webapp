Feature: Help wiki

  Have a wiki for help content. Allow editing articles and linking back and forth.

  Background: Set up the world and some users
    Given I have set up the world
      And a wiki front page
      And a user called "Admin" with username "admin" and password "aadmin" exists
      And "admin" is an admin
      And a user called "User" with username "user" and password "uuser" exists
      And a user called "Anonymous" with username "anon" and password "aanon" exists

  Scenario: Anonymous users should not see the wiki
    When I go to the home page
     And I make sure I'm logged out
    When I go to the wiki
    Then I should be told I have no access and I need to log in

  Scenario: Users should see wiki pages
   Given there is a wiki page "Salat"
     And the main page links to it
    When I log in as "user" with password "uuser"
     And I go to the wiki
    Then I should see the wiki front page
    When I follow "Salat" within "body"
    Then I should see the "Salat" wiki page

  Scenario: Users should not be able to edit or see history
    When I log in as "user" with password "uuser"
     And I go to the wiki
    Then I should not see "Edit"
     And I should not see "History"
    When I go to the wiki edit page
    Then I should see a message that I'm not allowed to do that

  @javascript
  Scenario: Admins should be able to edit pages
    When I log in as "admin" with password "aadmin"
     And I go to the wiki
    When I follow "Edit"
     And I fill in "page_content" with "[[Foo]]"
     And I press "Save page"
    Then I should see a "Foo" link on the page
    When I follow "Foo"
    Then I should land on the newly to be created "Foo" page

  @javascript 
  Scenario: Admins should be able to add media links
    When I log in as "admin" with password "aadmin"
   Given there is a media entry
    When I add a link "[media=xxx | Das Huhn ]" to it on the wiki front page and save
    Then I should see a "Das Huhn" link on the page
    When I follow "Das Huhn"
    Then I should see the media entry

  @javascript
  Scenario: Admins should be able to add video links
    When I log in as "admin" with password "aadmin"
   Given there is a media entry
    When I add a link "[video=xxx | Das Huhn ]" to it on the wiki front page and save
    Then I should see "Das Huhn" within "video"

  @javascript 
  Scenario: Admins should be able to add screenshots
    When I log in as "admin" with password "aadmin"
   Given there is a media entry
    When I add a link "[thumbnail=210 | Das Huhn ]" to it on the wiki front page and save
    Then there should be an image with title "Das Huhn"
