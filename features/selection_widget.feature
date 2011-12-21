Feature: Selection Widget for Sets in Sets and Entries in Sets

  In order to have a tool which provides functionalities for manage sets in sets
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
      