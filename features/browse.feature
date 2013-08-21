Feature: Browse media entries

  As a Madek user
  I want to find similar entries
  starting from a specific one

  @jsbrowser
  Scenario: Browse a media entry
    Given I am signed-in as "Normin"
    When I see a media entry
    Then I can browse for similar entries
