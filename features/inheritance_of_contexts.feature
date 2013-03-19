Feature: Inheritance of contexts

  As a MAdeK user
  I want add individual data to media entries
  So that I store my specialized meta data

  Scenario: Inherit contexts from another set
    Given I am "Normin"
    When I put a set A in set B that has any context
    Then the set A inherits all the contexts of the set B
    Then all media entries contained in set A have all contexts of set A

  Scenario: Disconnect contexts from a set
    Given I am "Normin"
    When I edit the contexts of a set that has contexts
    And I disconnect any contexts from that set
    Then those contexts are no longer connected to that set
    And all media entries contained in that set do not have the disconnected contexts any more
