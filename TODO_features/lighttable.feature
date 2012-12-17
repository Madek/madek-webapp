Feature: Lighttable that shows resources in more detail 

  @javascript
  Scenario: Zooming in on an image on the image's view page
    Given I am "Normin"
    When I open one of my media entries that is an image
     And I hover over the image
    Then I see a zoom icon
    When I click the zoom icon
    Then I see the image's preview in x_large size
     And the background is dimmed to black
  
  @javascript
  Scenario: Zooming in on an image on the image's edit page 
    Given I am "Normin"
    When I edit one of my media entries that is an image
     And I hover over the image
    Then I see a zoom icon
    When I click the zoom icon
    Then I see the image's preview in x_large size
     And the background is dimmed to black
