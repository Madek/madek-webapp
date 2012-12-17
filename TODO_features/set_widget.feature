Feature: Set Widget for Sets in Sets and Entries in Sets

  In order to have a tool which provides functionalities for manage sets in sets and entries in sets
  As a normal and expert user
  I want to have a widget which comes a long with features for: link, unlink, search and create sets on the fly

  Background: Set up the world some users, some sets and entries
    Given a user called "Max" with username "max" and password "password" exists
      
      And a set titled "My Act Photos" created by "max" exists
      And a entry titled "Me with Nothing" created by "max" exists
      And the last entry is child of the last set
   
      And a set titled "My Private Images" created by "max" exists
      And a entry titled "Me" created by "max" exists
      And the last entry is child of the last set
      And the last set is parent of the 1st set   
      And the set titled "My Act Photos" is child of the set titled "My Private Images"
        
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
      
      And I am "max"
      
  @javascript 
  Scenario: User goes to a set and opens the widget. The current set should not be visible.
    When I open the "My Act Photos" set
    And I open the selection widget for this set
    Then I should not see the "My Act Photos" set inside the widget

  
  @javascript 
  Scenario: User goes to a set and opens the widget. All editable sets should be visible and parent_sets of the set should already be checked.
    When I open the "My Act Photos" set
    And I open the selection widget for this set
    Then I should see the "My Private Images" set inside the widget
    And the "My_Private_Images" checkbox should be checked 
    And I should see the "My Public Images" set inside the widget
    And the "My_Public_Images" checkbox should not be checked
    And I should see the "Football Pics" set inside the widget
    And the "Football_Pics" checkbox should not be checked
    And I should see the "Images from School" set inside the widget
    And the "Images_from_School" checkbox should not be checked
    
  @javascript 
  Scenario: User goes to an entry and opens the widget. All editable sets should be visible and media_sets of the entry should already be checked.
    When I open the "Me with Nothing" entry
    And I open the selection widget for this entry
    Then I should see the "My Private Images" set inside the widget
    And the "My_Private_Images" checkbox should not be checked
    And I should see the "My Act Photos" set inside the widget
    And the "My_Act_Photos" checkbox should be checked
    And I should see the "My Public Images" set inside the widget
    And the "My_Public_Images" checkbox should not be checked
    And I should see the "Football Pics" set inside the widget
    And the "Football_Pics" checkbox should not be checked
    And I should see the "Images from School" set inside the widget
    And the "Images_from_School" checkbox should not be checked
      
  @javascript 
  Scenario: User goes to a set and adds multiple sets to the parent sets
    When I open the "Images from School" set
    And I open the selection widget for this set
    And I select "My_Public_Images" as parent set
    And I select "My_Private_Images" as parent set
    And I submit the selection widget
    And I open the "Images from School" set
    And I open the selection widget for this set
    Then I should see the "My Private Images" set inside the widget
    And the "My_Private_Images" checkbox should be checked
    And the "My_Public_Images" checkbox should be checked
    
  @javascript 
  Scenario: User goes to an entry and add one set and remove another set from the parent sets
    When I open the "My Profile Pic" entry
    And I open the selection widget for this entry
    And I deselect "My_Public_Images" as parent set
    And I select "My_Private_Images" as parent set
    And I submit the selection widget
    And I open the "My Profile Pic" entry
    And I open the selection widget for this entry
    Then I should see the "My Private Images" set inside the widget
    And the "My_Private_Images" checkbox should be checked
    And the "My_Public_Images" checkbox should not be checked

  @javascript 
  Scenario: User goes to a set and create multiple sets and add one of them to the parent sets
    When I open the "Images from School" set
    And I open the selection widget for this set
    And I create a new set named "Education Images"
    And I create a new set named "Free Time Images"
    And I deselect "Free_Time_Images" as parent set
    And I submit the selection widget
    And I open the "Images from School" set
    And I open the selection widget for this set
    Then I should see the "Education Images" set inside the widget
    And the "Education_Images" checkbox should be checked
    And I should see the "Free Time Images" set inside the widget
    And the "Free_Time_Images" checkbox should not be checked
  
  @javascript 
  Scenario: User goes to an entry, openes the selection widget and searches for a set. After he doesnt found it, he creates it and adds it to the parent sets - the name for the set was already provided from his search
    When I open the "Images from School" set
    And I open the selection widget for this set
    And I search for "my"
    And I should see the "My Act Photos" set inside the widget
    And I should see the "My Private Images" set inside the widget
    And I should see the "My Public Images" set inside the widget
    And I should not see the "Education Images" set inside the widget
    And I search for "My New Images"
    And I create a new set
    And I submit the selection widget
    And I open the "Images from School" set
    And I open the selection widget for this set
    Then I should see the "My New Images" set inside the widget
    And the "My_New_Images" checkbox should be checked

  @javascript 
  Scenario: More then 36 items in a set widget
    When I open the "My Profile Pic" entry
     And I open the selection widget for this entry
     And I create 40 sets
     And I submit the selection widget
     And I open the "Images from School" set
     And I open the selection widget for this set
    Then I see at least 40 entries in the set widget


  # Not yet implemented:
  # And I can filter for my sets # The "my" is not defined yet!
  #
