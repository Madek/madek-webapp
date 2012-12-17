Feature: Not logged in user

  As a not logged in MAdeK user
  I am not able to use all actions in MAdeK
  
  @javascript
  Scenario: Actions for not logged in users
   Given I am not logged in
   Then I can see the explore page
   Then I can see the search page
   Then I see the help tab and can link to the help
   Then I see only resources that have public permissions
   Then I can edit only resources that have public edit permissions
   Then I can download resources in original size and format only when the public is allowed to
   Then I can not see the access permissions of resources
   
