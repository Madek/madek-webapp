Feature: Login

  As a MAdeK user

  Background: Load the example data and personas
    Given I have set up the world a little
      And personas are loaded
      And I am "Normin"

  @javascript
  Scenario: Context actions on the set detail view
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | action name |
    | edit |
    | favorite |
    | permissions |
    | add to set |
    | set highlight |
    | set cover |
    | save display settings |
    | create set |
    | delete |

  @javascript
  Scenario: Context actions on the media entry detail view
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | action name |
    | edit |
    | favorite |
    | browse |
    | permissions |
    | add to set |
    | export |
    | create set |
    | delete |

  @javascript
  Scenario: Context actions on the search result page
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | create set |

  @javascript
  Scenario: Context actions on the group page
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | create group |

  @javascript
  Scenario: Context actions on the favorite view
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | create set |

  @javascript
  Scenario: Context actions on the my media entries view
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | create set |

  @javascript
  Scenario: Context actions on the my sets view
    When ...
    Then I can open the context actions drop down and see the following actions in the following order:
    | create set |