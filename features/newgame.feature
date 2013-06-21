Feature: Newgame

  Scenario: A student creates a new game
    Given   a student
    And     user is not in a group
    When the user click on "new game"
    Then a new game is created with one level

