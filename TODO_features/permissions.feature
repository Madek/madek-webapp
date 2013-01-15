   # https://www.pivotaltracker.com/story/show/35836615
  @javascript
  Scenario: Display the complete LDAP name on the selection dropdown
    Given I am "Normin"
      And I have set up some departments with ldap references
     When I open one of my resources
      And I open the permission lightbox
      And I add "Vertiefung Industrial Design (DDE_FDE_VID.dozierende)" to grant group permissions

    
