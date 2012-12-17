Feature: Logged in user

  As a logged in MAdeK user
  I am able to use more actions in MAdeK than a not logged in user

  @javascript
  Scenario: Actions for logged in users
   Given I am "Normin"
   Then I can see the clipboard
   Then I can add resources to the clipboard
	Then I can see my archive
   Then I can see my favorites page
   Then I can add resources to my favorites
      Then I can import media
   Then I can see my last import page
   Then I can create a set
   Then I can create a filter set
   Then I can see my sets page
   Then I can see my content page
   Then I can see the page with content related to me
   Then I can see the page with my keywords
   Then I can see the content related actions
   Then I can see my groups

