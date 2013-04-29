Feature: Delete

  As a MAdeK user 
  I want to be able to delete resources that I am responsible for
  So that I can remove things I dont want anymore

  @jsbrowser @clean
  Scenario: Access delete action for media resources on my dashboard
    Given I am signed-in as "Normin"
    And I am on the dashboard
    Then I can see the delete action for media resources where I am responsible for
    And I cannot see the delete action for media resources where I am not responsible for

  @jsbrowser @clean
  Scenario: Access delete action for media resources on a media resources list
   Given I am signed-in as "Normin"
    When I see a list of resources 
    Then I can see the delete action for media resources where I am responsible for
    And I cannot see the delete action for media resources where I am not responsible for

  @jsbrowser @clean
  Scenario: Access delete action for media entry on media entry page
   Given I am signed-in as "Normin"
    When I open a media entry where I have all permissions but I am not the responsible user
    Then I cannot see the delete action for this resource
    When I open a media entry where I am the responsible user
    Then I can see the delete action for this resource

  @jsbrowser @clean
  Scenario: Access delete action for media set on media set page
   Given I am signed-in as "Normin"
   When I open a media set where I have all permissions but I am not the responsible user
   Then I cannot see the delete action for this resource
   When I open a media set where I am the responsible user
   Then I can see the delete action for this resource
