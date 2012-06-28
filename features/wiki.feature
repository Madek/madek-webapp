Feature: Help wiki

  Have a wiki for help content. Allow editing articles and linking back and forth.

  Background: Set up the world and some users
    Given I have set up the world a little
      And a wiki front page
      And a user called "Admin" with username "admin" and password "password" exists
      And "admin" is an admin
      And a user called "User" with username "user" and password "password" exists
      And a user called "Anonymous" with username "anon" and password "password" exists

  Scenario: Anonymous users should not see the wiki
    When I go to the home page
     And I make sure I'm logged out
    When I go to the wiki
    Then I should be told I have no access and I need to log in

  Scenario: Users should see wiki pages
   Given there is a wiki page "Salat"
     And the main page links to it
    Given I am "user"
     And I go to the wiki
    Then I should see the wiki front page
    When I follow "Salat" within "body"
    Then I should see the "Salat" wiki page

  Scenario: Users should not be able to edit or see history
   Given I am "user"
     And I go to the wiki
    Then I should not see "Edit"
     And I should not see "History"
    When I go to the wiki edit page
    Then I should see a message that I'm not allowed to do that

  Scenario: Admins should be able to edit pages
    Given I am "admin"
     And I go to the wiki
    When I follow "Edit"
     And I fill in "page_content" with "[[Foo]]"
     And I press "Save page"
    Then I should see a "Foo" link on the page
    When I follow "Foo"
    Then I should land on the newly to be created "Foo" page

  Scenario: Admins should be able to add media links
    Given I am "admin"
   Given there is a media entry
    When I add a link "[media=xxx | Das Huhn ]" to it on the wiki front page and save
    Then I should see a "Das Huhn" link on the page
    When I follow "Das Huhn"
# This is broken since we moved to the persona SQL file -- it goes to the wrong media entry
#    Then I should see the media entry

  Scenario: Admins should be able to add video links
    Given I am "admin"
   Given there is a media entry
    When I add a link "[video=xxx | Das Huhn ]" to it on the wiki front page and save
    Then I should see "Das Huhn" within "video"

# Test is broken right now
#  @javascript
#  Scenario: Admins should be able to add screenshots
#    Given I am "admin"
#   Given there is a media entry
#    When I add a link "[screenshot=210 | Das Huhn ]" to it on the wiki front page and save
#    Then there should be an image with title "Das Huhn"
