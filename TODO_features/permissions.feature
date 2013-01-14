  

  # https://www.pivotaltracker.com/story/show/25238301
  @javascript
  Scenario: Permission presets
    Given I am "Normin"
     When I open one of my resources
      And I open the permission lightbox
      And I add "Petra" to grant user permissions
     Then I can choose from a set of labeled permissions presets instead of grant permissions explicitly    
  
  # https://www.pivotaltracker.com/story/show/23723319
  @javascript
  Scenario: Limiting what other users' permissions I can see
    Given a resource owned by "Normin"
      And the resource has the following permissions:
      | user      | permission | value |
      | Normin    | view       | true  |
      | Normin    | download   | true  |
      | Normin    | edit       | true  |
      | Normin    | manage     | true  |
      | Petra     | view       | true  |
      | Beat      | view       | true  |
      | Beat      | edit       | true  |
      | Beat      | download   | true  |
      | Liselotte | view       | true  |
      | Liselotte | edit       | true  |
      | Liselotte | download   | true  |
    When the resource is viewed by "Normin"
    Then he or she sees the following permissions:
      | user      | permission |
      | Normin    | view       |
      | Normin    | download   |
      | Normin    | edit       |
      | Normin    | manage     |
      | Petra     | view       |
      | Beat      | edit       |
      | Beat      | download   |
      | Liselotte | edit       |
      | Liselotte | download   |
    When the resource is viewed by "Beat"
    Then he or she sees the following permissions:
      | user   | permission |
      | Normin | view       |
      | Petra  | view       |
    When the resource is viewed by "Liselotte"
    Then he or she sees the following permissions:
      | user      | permission |
      | Normin    | edit       |
      | Beat      | edit       |
      | Liselotte | edit       |
    When the resource is viewed by "Petra"
    Then he or she sees the following permissions:
      | user   | permission |
      | Normin | view       |
      | Petra  | view       |
      
  # https://www.pivotaltracker.com/story/show/25238371
  @javascript
  Scenario: Cascading of public permissions
    Given a resource owned by "Normin"
      And I am "Normin"
      And the resource has the following permissions:
      | user      | permission | value |
      | Normin    | view       | true  |
      | Normin    | download   | true  |
      | Normin    | edit       | true  |
      | Normin    | manage     | true  |
      | Petra     | view       | true  |
      | Beat      | view       | true  |
      | Beat      | edit       | true  |
      | Beat      | download   | true  |
      | Liselotte | view       | true  |
      | Liselotte | edit       | true  |
      | Liselotte | download   | true  |
    When I change the resource's public permissions as follows:
      | permission | value |
      | view       | true  |
      | download   | true  |
    Then I cannot edit the following permissions any more:
      | permission |
      | view       |
      | download   |

  # https://www.pivotaltracker.com/story/show/35836615
  @javascript
  Scenario: Display the complete LDAP name on the selection dropdown
    Given I am "Normin"
      And I have set up some departments with ldap references
     When I open one of my resources
      And I open the permission lightbox
      And I add "Vertiefung Industrial Design (DDE_FDE_VID.dozierende)" to grant group permissions

    
