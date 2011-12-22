Feature: Selection Widget for Sets in Sets and Entries in Sets

  In order to have a tool which provides functionalities for manage sets in sets and entries in sets
  As a normal and expert user
  I want to have a widget which comes a long with features for: link, unlink, search and create sets on the fly

  Background: Set up the world some users, some sets and entries
    Given I have set up the world
      And a user called "Max" with username "max" and password "moritz" exists
      
      And a set titled "My Act Photos" created by "max" exists
      And a entry titled "Me with Nothing" created by "max" exists
      And the last entry is child of the last set
   
      And a set titled "My Private Images" created by "max" exists
      And a entry titled "Me" created by "max" exists
      And the last entry is child of the last set
      And the last set is parent of the 1st set   
        
      And a set titled "My Public Images" created by "max" exists
      And a entry titled "My Profile Pic" created by "max" exists
      And the last entry is child of the last set
      
      And a set titled "Football Pics" created by "max" exists
      And a entry titled "Me and my Balls" created by "max" exists
      And the last entry is child of the last set
      And the last set is parent of the 3rd set
      
      And a set titled "Images from School" created by "max" exists
      And a entry titled "Me with School Uniform" created by "max" exists
      And the last entry is child of the last set
  
  @javascript
  Scenario: Go to a set and open the widget. All editable sets should be visible and parent_sets of the set should already be checked.
    When I log in as "max" with password "moritz"
    And I open the "My Act Photos" set
    And I open the selection widget in "#set_actions"
    And I wait for the CSS element ".widget .list"
    Then I should see "My Private Images"
    And the "My_Private_Images" checkbox should be checked 
    And I should see "My Public Images"
    And the "My_Public_Images" checkbox should not be checked
    And I should see "Football Pics"
    And the "Football_Pics" checkbox should not be checked
    And I should see "Images from School"
    And the "Images_from_School" checkbox should not be checked
    
  @javascript
  Scenario: Go to a entry and open the widget. All editable sets should be visible and media_sets of the entry should already be checked.
    When I log in as "max" with password "moritz"
    And I open the "Me with Nothing" entry
    And I open the selection widget in "#detail-action-bar"
    And I wait for the CSS element ".widget .list"
    Then I should see "My Private Images"
    And the "My_Private_Images" checkbox should not be checked
    And I should see "My Act Photos"
    And the "My_Act_Photos" checkbox should be checked
    And I should see "My Public Images"
    And the "My_Public_Images" checkbox should not be checked
    And I should see "Football Pics"
    And the "Football_Pics" checkbox should not be checked
    And I should see "Images from School"
    And the "Images_from_School" checkbox should not be checked
      
  @javascript
  Scenario: Go to a set and add multiple sets to the parent_sets
    When I log in as "max" with password "moritz"
    And I open the "Images from School" set
    And I open the selection widget in "#set_actions"
    And I wait for the CSS element ".widget .list"
    And I select "My_Public_Images" as parent set
    And I select "My_Private_Images" as parent set
    And I submit the selection widget
    And I wait for the CSS element ".has-selection-widget:not(.open)"
    And I open the "Images from School" set
    And I open the selection widget in "#set_actions"
    And I wait for the CSS element ".widget .list"
    Then I should see "My Private Images"
    And the "My_Private_Images" checkbox should be checked
    And the "My_Public_Images" checkbox should be checked
    
  @javascript @current
  Scenario: Go to a entry and add one set and remove another set from the parent_sets
    When I log in as "max" with password "moritz"
    And I open the "My Profile Pic" entry
    And I open the selection widget in "#detail-action-bar"
    And I wait for the CSS element ".widget .list"
    And I deselect "My_Public_Images" as parent set
    And I select "My_Private_Images" as parent set
    And I submit the selection widget
    And I wait for the CSS element ".has-selection-widget:not(.open)"
    And I open the "My Profile Pic" entry
    And I open the selection widget in "#detail-action-bar"
    Then I should see "My Private Images"
    And the "My_Private_Images" checkbox should be checked
    And the "My_Public_Images" checkbox should not be checked

  @javascript
  Scenario: Go to a set and create multiple sets and add one of them to the parent_sets
    When I log in as "max" with password "moritz"
    And I open the "Images from School" set
    And I open the selection widget in "#detail-action-bar"
    And I wait for the CSS element ".widget .list"
    Then I should see "My Private Images"
  
  @javascript
  Scenario: Go to a entry search for a set and add this to the parent_sets
  
  @javascript
  Scenario: Heavy using of the selection widget
