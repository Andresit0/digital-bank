Feature: View customer accounts

  Scenario: Customer with accounts
    Given the customer is authenticated
    When the accounts are loaded
    Then the customer sees their accounts
    And the available balance is displayed

  Scenario: No accounts
    Given the customer is authenticated
    And the customer has no accounts
    When the accounts are loaded
    Then the empty state is displayed
    And the empty state is not an error

  Scenario: Accounts loading
    Given the customer is authenticated
    When the accounts request is in progress
    Then a loading state is displayed

  Scenario: Accounts failure
    Given the customer is authenticated
    And the accounts request fails
    When the accounts are loaded
    Then a failure state is displayed

  Scenario: Not authenticated
    Given the customer is not authenticated
    When the customer opens the accounts area
    Then the customer is redirected to login
