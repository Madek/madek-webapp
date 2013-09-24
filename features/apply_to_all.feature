Feature: Applying meta data to other media entries

  As a Madek user
  I want to apply meta data to multiple other media entries
  to save time

  @firefox
  Scenario: Where I can apply meta data to other media entries
    Given I am signed-in as "Normin"
    When I upload some media entries
    Then I can apply meta data from one specific field to the same field of multiple other media entries of the collection

  @firefox
  Scenario: Overwrite meta data during apply all during import
    Given I am signed-in as "Normin"
    When I upload some media entries
     And I apply each meta datum field of one media entry to all other media entries of the collection using overwrite functionality
    Then all other media entries have the same meta data values

  @firefox
  Scenario: Apply only on empty meta data fields during import
    Given I am signed-in as "Normin"
    When I upload some media entries
    And I apply each meta datum field of one media entry to all other media entries of the collection using apply on empty functionality
    Then all other media entries have the same meta data values in those fields that were empty before
