Feature: Edit the permissions through batch-edit

  Background: 
    Given I am signed-in as "Normin"
    Given A resource owned by me with no other permissions
      And The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Given A second resource owned by me with no other permissions
      And The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | fase  |
    When I add the resource and the second resource to the clipboard
    When I click on the link "Zwischenablage"
    Then I can see the resource and the second resource in the clipboard 
    When I click on the link "Aktionen" in the clipboard 
    And I click on the link "Berechtigungen Verwalten" 
    Then The permissions dialog opens 
    Then I see the following permissions-state:
      | user      | permission | state  |
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | mixed |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | mixed |
      | Petra     | manage     | mixed |
      | Karen     | view       | mixed |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |


  Scenario: Saving without changing anything
    When I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

    
  Scenario: 
    When I click on the "manage" permission for Petra until it is "false"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | false |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  Scenario: 
    When I click on the "manage" permission for Petra until it is "true"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | true  |

  Scenario: 
    When I click on the "manage" permission for Petra until it is "mixed"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  Scenario: Creating a new user permission 
    When I click on the "manage" permission for Karen until it is "true"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | true  |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |
      | Karen     | view       | false |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | true  |


  Scenario: Changing public permissions doesn't change userpermission
    When I click on the public "view" permission until it is "true"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  Scenario: Changing public permissions doesn't change userpermission
    When I click on the public "download" permission until it is "true"
    And I click on the link "Speichern" 
    Then The resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | false |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | true  |
      | Karen     | view       | true  |
      | Karen     | edit       | false |
      | Karen     | download   | false |
      | Karen     | manage     | false |
    Then The second resource has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |
