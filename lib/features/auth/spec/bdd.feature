Feature: Customer authentication

  Scenario: Successful authentication
    Given the customer has valid credentials
    When the customer submits the login form
    Then the customer is authenticated
    And the application navigates to the authenticated area

  Scenario: Invalid credentials
    Given the customer enters invalid credentials
    When the customer submits the login form
    Then authentication fails
    And the customer remains unauthenticated
    And an authentication error is displayed

  Scenario: Network failure
    Given the customer submits valid credentials
    And the network request fails
    When authentication is attempted
    Then the customer remains unauthenticated
    And a recoverable error is displayed

  Scenario: Access to the authenticated area
    Given the customer is authenticated
    When the application evaluates routing
    Then the authenticated area is accessible

  Scenario: Protected area without session
    Given the customer is not authenticated
    When the customer opens the protected area
    Then the customer is redirected to login

  Scenario: Logout
    Given the customer is authenticated
    When the customer logs out
    Then the session is cleared
    And the customer returns to the login screen
