Feature: Onboarding

  Scenario: First launch for a new customer
    Given the customer has not completed onboarding
    When the application starts
    Then onboarding is presented before authentication

  Scenario: Advancing through onboarding
    Given the customer is on an onboarding step
    When the customer taps Next
    Then the next step is presented
    And the progress indicator advances

  Scenario: Skipping onboarding
    Given the customer is on onboarding
    When the customer taps Skip
    Then onboarding is completed

  Scenario: Completing onboarding
    Given the customer is on the last onboarding step
    When the customer finishes onboarding
    Then onboarding is persisted as completed
    And the customer is taken to login

  Scenario: Returning customer
    Given the customer completed onboarding
    When the application starts
    Then onboarding is not presented
    And the customer is taken to login

  Scenario: Logout does not reset onboarding
    Given the customer completed onboarding and is authenticated
    When the customer logs out
    Then the customer returns to login
    And onboarding is not presented again
