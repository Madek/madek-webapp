Feature: Admin interface: Become superuser

  As a MAdeK admin
  I want to switch into a superuser mode
  So that I can see everyone's media entries without any respect for their permissions

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Switching to superuser mode
    Given I am flagged as an admin user
    When I switch to superuser mode
    Then all permissions on media entries are ignored for me and I automatically have all permissions on everything

  Scenario: Switching out of superuser mode
    Given I am switched into superuser mode
    When I switch out of superuser mode
    Then I am who I was before I became superuser
    And my normal permissions apply again
