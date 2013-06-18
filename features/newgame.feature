Feature: Newgame

  Scenario: A user creates a new game
    Given the user is signed_in
    And   user is not linked to a group
    When the user click on "new game"
    Then a new game is created with one level

  Scenario: Professor delete a group
    Given the professor owns the group
    When the professor click on "delete group"
    Then users in the group are deleted
    And  group is deleted 

  Scenario: Professor create some users for the group
    Given the professor needs 5 users
    When the professor click on "generate users"
    Then 5 users are created with random password
    And  users are linked to the group
    And  a new game is created for users with one level
    And  a report is sent to the professor
