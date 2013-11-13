Feature: Transfer responsibility

  Scenario: Transferring one media resource as an owner
    Given I am signed-in as "Normin"
    And I remove all permissions from my first media_entry
    And I visit the path of my first media entry
    And I remember this media_resource
    And I open the transfer responsibility page for this resource
    And I set the input with the name "user" to "[petra]"
    And I submit
    Then The owner of the media_resource is "petra"
    And The resource has the following user-permissions:
    | user      | permission | value |
    | Normin    | view       | true  |
    | Normin    | download   | true  |
    | Normin    | edit       | true  |
    | Normin    | manage     | true  |


  Scenario: Transferring a media resource where I am not the owner
    Given I am signed-in as "Normin"
    And I remove all permissions from my first media_entry
    And I visit the path of my first media entry
    And I remember this media_resource
    And I open the transfer responsibility page for this resource
    And I set the input with the name "user" to "[petra]"
    And I submit
    Then The owner of the media_resource is "petra"
    And The resource has the following user-permissions:
      | user      | permission | value |
      | Normin    | view       | true  |
      | Normin    | download   | true  |
      | Normin    | edit       | true  |
      | Normin    | manage     | true  |
    When I visit the path of the resource
    And I open the transfer responsibility page for this resource
    And I set the input with the name "user" to "[normin]"
    And I submit
    Then The owner of the media_resource is "petra"

  Scenario: Setting custom permissions
    Given I am signed-in as "Normin"
    And I remove all permissions from my first media_entry
    And I visit the path of my first media entry
    And I remember this media_resource
    And I open the transfer responsibility page for this resource
    And I set the input with the name "user" to "[petra]"
    When I click on the "view" permission until it is "false"
    When I click on the "download" permission until it is "false"
    When I click on the "edit" permission until it is "false"
    When I click on the "manage" permission until it is "false"
    And I submit
    Then The owner of the media_resource is "petra"
    And The resource has the following user-permissions:
    | user      | permission | value |
    | Normin    | view       | true  |
    | Normin    | download   | true  |
    | Normin    | edit       | false |
    | Normin    | manage     | false |

    
  @jsbrowser
  Scenario: Transfering responsibility as uberadmin
    Given I am signed-in as "Adam"
    And I switch to uberadmin modus
    And I remove all permissions from "Normin"\'s first media_entry
    And I visit the path of "Normin"\'s first media entry
    And I remember this media_resource
    And I open the transfer responsibility page for this resource
    And I set the input with the name "user" to "[petra]"
    And I submit
    Then The owner of the media_resource is "petra"
    And The resource has the following user-permissions:
    | user      | permission | value |
    | Normin    | view       | true  |
    | Normin    | download   | true  |
    | Normin    | edit       | true  |
    | Normin    | manage     | true  |

