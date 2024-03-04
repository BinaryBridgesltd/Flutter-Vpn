class PingResult {
  final PingStatus status;
  final int pingTime; // in milliseconds

  PingResult(this.status, {this.pingTime = -1});
}

enum PingStatus {
  success,
  failure,
}
