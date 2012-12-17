Feature: Context related actions

  As a MAdeK user

  Background: Load the example data and personas
    Given personas are loaded

  @poltergeist
  Scenario: Context actions on the set detail view
    Given I am "Normin"
    When I open a set that I can edit which has children
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | edit |
    | favorite |
    | permissions |
    | add to set |
    | add to clipboard |
    | set highlight |
    | set cover |
    | save display settings |
    | create set |
    | delete |
    | show graph |

  @poltergeist
  Scenario: Context actions on the media entry detail view
   Given I am "Normin"
    When I open one of my resources
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | edit |
    | favorite |
    | browse |
    | permissions |
    | add to set |
    | add to clipboard |
    | export |
    | create set |
    | delete |
    | show graph |

  @poltergeist
  Scenario: Context actions on the search result page
   Given I am "Normin"
    When I see some search results
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | import |
    | create set |
    | show graph |

  @poltergeist
  Scenario: Context actions on the filter set detail view
   Given I am "Adam"
    When I open a filter set that I can edit
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | edit |
    | favorite |
    | permissions |
    | add to set |
    | save display settings |
    | create set |
    | delete |
    | show graph |

  @poltergeist
  Scenario: Context actions on the group page
   Given I am "Normin"
    When I click the arrow next to my name
     And I follow "Meine Arbeitsgruppen"
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | create group |

  @poltergeist
  Scenario: Context actions on the favorite view
   Given I am "Normin"
    When I click the arrow next to my name
     And I follow "Meine Favoriten"
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | create set |
    | import |
    | show graph |

  @poltergeist
  Scenario: Context actions on the my media entries view
   Given I am "Normin"
    When I click the arrow next to my name
     And I follow "Meine Medieneinträge"
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | create set |
    | import |
    | show graph |

  @poltergeist
  Scenario: Context actions on the my sets view
   Given I am "Normin" 
    When I click the arrow next to my name
     And I follow "Meine Sets"
    Then I can open the context actions drop down and see the following actions in the following order:
    | action |
    | create set |
    | import |
    | show graph |
