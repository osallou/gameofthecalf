Feature: Newgame

  Scenario: A user creates a new game
    Given the user is signed_in
    When the user click on "new game"
    Then a new game is created with one level
