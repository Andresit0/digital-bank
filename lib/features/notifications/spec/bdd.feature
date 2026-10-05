Feature: Firebase Cloud Messaging notifications

  Scenario: Request notification permission
    Given the customer is authenticated on Android
    When the application requests the notification permission
    Then the permission result is granted or denied
    And a denial is not treated as a crash

  Scenario: Obtain the FCM registration token
    Given Firebase is initialized on Android
    When the application requests the FCM registration token
    Then the token is available
    And the token is never logged or shown

  Scenario: Token refresh
    Given the registration token was obtained
    When Firebase emits a token refresh
    Then the updated token is propagated
    And the device installation is updated

  Scenario: Receive a notification in the foreground
    Given the application is in the foreground
    When an FCM message arrives
    Then it is converted into a domain notification

  Scenario: Open a notification from the background
    Given the application is in the background
    When the customer taps the notification
    Then a navigation intent is exposed

  Scenario: Open a notification from a terminated state
    Given the application was terminated
    When the customer taps the notification to launch it
    Then the initial message is exposed as a navigation intent

  Scenario: Movement notification navigates
    Given a movement notification intent
    When the customer opens it
    Then the application navigates to Movements

  Scenario: Notification failure does not crash
    Given a token or messaging failure
    When the failure occurs
    Then the application represents it without crashing
