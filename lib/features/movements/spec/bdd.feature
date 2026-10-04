Feature: Movements

  As an authenticated customer
  I want to see the movements of my account and inspect a movement
  So that I can understand my account activity

  Scenario: Load the movements of the account selected in the navigation context
    Given the customer is authenticated
    And the customer opens the Accounts screen
    When the customer taps an account card
    Then the application navigates to /movements with the accountId query parameter
    And the movements of that account are requested from GET /accounts/{accountId}/movements
    And the MovementsLoaded state is represented
    And the loaded movements are displayed

  Scenario: Empty movement history
    Given the customer is authenticated
    And the movements request for the accountId returns an empty list
    When the movements of the accountId are requested
    Then the MovementsEmpty state is represented
    And an empty state is displayed
    And the empty state is not an error

  Scenario: Movement list failure
    Given the customer is authenticated
    And the movements request for the accountId fails
    When the movements of the accountId are requested
    Then the MovementsFailure state carries an AppError
    And a movements_load_failed operational event is reported once

  Scenario: Open a movement detail from the loaded list
    Given the authenticated customer is on the Movements screen
    And the movements of the selected account are loaded
    When the customer taps a movement
    Then the application navigates to /movements/:id
    And the detail is rendered from the already loaded movement
    And no additional HTTP request is performed

  Scenario: Unauthenticated access is redirected
    Given the customer is not authenticated
    When the customer opens /movements
    Then the application redirects to the login screen
