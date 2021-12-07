class IllegalArgumentSearch implements Exception {
  final String message;

  IllegalArgumentSearch(this.message) : super();

  @override
  String toString() {
    return message;
  }
}
