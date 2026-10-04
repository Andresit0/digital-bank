Feature: Dynamic experience on Home

  Scenario: Experience loaded with supported sections
    Given the customer is authenticated
    And the server returns a valid experience definition
    When Home requests the experience
    Then the supported sections are rendered
    And the promotion and quick action are visible

  Scenario: No dynamic sections
    Given the customer is authenticated
    And the server returns a valid definition with no sections
    When Home requests the experience
    Then the experience is empty
    And the static fallback is shown

  Scenario: Unsupported section ignored
    Given the customer is authenticated
    And the server returns a definition containing an unsupported section type
    When Home requests the experience
    Then the unsupported section is ignored
    And the supported sections are rendered

  Scenario: Invalid configuration
    Given the customer is authenticated
    And the server returns a definition that does not match the schema
    When Home requests the experience
    Then the experience fails with an invalid configuration error
    And the static fallback is shown

  Scenario: Server error
    Given the customer is authenticated
    And the server returns a server error
    When Home requests the experience
    Then the experience fails with a network error
    And the static fallback is shown

  Scenario: Transport failure
    Given the customer is authenticated
    And the network request fails
    When Home requests the experience
    Then the experience fails with a network error
    And the static fallback is shown

  Scenario: Quick action intent
    Given a loaded experience contains a quick action
    When the customer taps the quick action
    Then the action is expressed as a controlled intent
    And Home resolves the navigation
