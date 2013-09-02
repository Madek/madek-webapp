Feature: Admin interface: Configure footer and logo
  As a MAdeK admin
  I want to configure the logo and links on the splash page
  So my Madek instance looks different than other people's instances

  Background: 
    Given I am signed-in as "Adam"

  Scenario: Configuring footer links
    When I add some links for footer in the admin interface
    Then Those links appear in the footer of the path "/my" 
    Then Those links appear in the footer of the path "/media_resources" 
    Then Those links appear in the footer of the path "/media_entries/65"

  Scenario: Specifying a logo for the instance
    When I configure some logo_url as the logo of my instance
    Then This logo_url appears as the logo of this instance
