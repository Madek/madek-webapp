Feature: Edit the permissions through batch-edit

  Background: 
    Given I am signed-in as "Normin"
    Given A resource1 owned by me with no other permissions
      And The resource1 has the following user-permissions:
      | user      | permission | value |
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
    Given A resource2 owned by me with no other permissions
      And The resource2 has the following user-permissions:
      | user      | permission | value |
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | fase  |
    When I add the resource1 to the clipboard
    And I add the resource2 to the clipboard
    And I visit "/my"
    When I click on the link "Zwischenablage"
    And I wait for the clipboard to be fully open
    Then I can see the resource1 in the clipboard 
    And I can see the resource2 in the clipboard 
    When I click on the link "Aktionen" in the clipboard 
    And I click on the link "Berechtigungen verwalten" 
    Then I can see the permissions dialog

  @jsbrowser
  Scenario: Looking at the permission properties 
    Then I can see the following permissions-state:
      | user      | permission | state |
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


  @jsbrowser
  Scenario: Saving without changing anything
    When I click on "Speichern" 
    Then The resource1 has the following user-permissions set:
      | user      | permission | state |
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
    Then The resource2 has the following user-permissions set:
      | user      | permission | state |
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | true  |
      | Petra     | manage     | false |

    
  @jsbrowser
  Scenario: Disabling a manage permission
    When I click on the "manage" permission for "Petra" until it is "false"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  @jsbrowser
  Scenario: Enabling manage permissions
    When I click on the "manage" permission for "Petra" until it is "true"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | true  |

  @jsbrowser
  Scenario: Keeping mixed state
    When I click on the "manage" permission for "Petra" until it is "mixed"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  @jsbrowser
  Scenario: Creating a new user permission 
    When I click on the "manage" permission for "Karen" until it is "true"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
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


  @jsbrowser 
  Scenario: Changing public permissions doesn't change userpermission
    When I click on the public "view" permission until it is "true"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |

  @jsbrowser
  Scenario: Changing public permissions doesn't change userpermission
    When I click on the public "download" permission until it is "true"
    And I click on "Speichern" 
    Then The resource1 has the following user-permissions:
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
    Then The resource2 has the following user-permissions:
      | Liselotte | view       | true  |
      | Liselotte | edit       | false |
      | Liselotte | download   | true  |
      | Liselotte | manage     | true  |
      | Petra     | view       | true  |
      | Petra     | edit       | true  |
      | Petra     | download   | false |
      | Petra     | manage     | false |
