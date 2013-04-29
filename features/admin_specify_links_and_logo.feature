Feature: Admin interface: Configure footer and logo
  As a MAdeK admin
  I want to configure the logo and links on the splash page
  So my Madek instance looks different than other people's instances
  
  Background: 
    Given I am signed-in as "Adam"

  Scenario: Configuring links
    When I add any links for the splash page through the admin interface
    Then those links appear in the footer of every page

  Scenario: Specifying a logo for the instance
    Given there is a publicly downloadable media entry in PNG format that represents my logo
    When I configure this media entry to be my instance logo
    Then this logo appears as the logo of this instance

  Scenario: Having no logo
    When there is no logo specified for this instance
    Then no logo appears for this instance
