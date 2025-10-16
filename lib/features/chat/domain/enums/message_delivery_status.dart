/// Message delivery status enum
///
/// Represents the current delivery state of a chat message
enum MessageDeliveryStatus {
  /// Message has been sent from the client
  sent,

  /// Message has been delivered to the server
  delivered,

  /// Message has been seen by the recipient
  seen,

  /// Status cannot be determined
  unknown,
}
