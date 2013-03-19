Feature: Applying meta data to other media entries

    As a Madek user
    I want to apply meta data to multiple other media entries
    to save time

  Scenario: Where I can apply meta data to other media entries
    Given I am "Normin"
    When I upload media entries
    Then I can apply meta data from one specific field to the same field of multiple other media entries of the collection
    When I edit meta data using batch edit
    Then I can apply meta data from one specific field to the same field of multiple other media entries of the collection

  Scenario: Overwrite meta data during apply all during batch edit
    Given I am "Normin"
    When I upload media entries
     And I apply each meta datum field of one media entry to all other media entries of the collection using overwrite functionality
    Then all other media entries have the same meta data values

  Scenario: Overwrite meta data during apply all during upload
    Given I am "Normin"
    When I batch edit media entries
     And I apply each meta datum field of one media entry to all other media entries of the collection using overwrite functionality
    Then all other media entries have the same meta data values 

  Scenario: Apply only on empty meta data fields during batch edit
    Given I am "Normin"
    When I batch edit media entries
    And I apply each meta datum field of one media entry to all other media entries of the collection using apply on empty functionality
    Then all other media entries have the same meta data values in those fields that were empty before
    
  Scenario: Apply only on empty meta data fields during upload
    Given I am "Normin"
    When I upload media entries
    And I apply each meta datum field of one media entry to all other media entries of the collection using apply on empty functionality
    Then all other media entries have the same meta data values in those fields that were empty before