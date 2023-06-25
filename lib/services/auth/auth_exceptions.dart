// Login Exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register Exceptions

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

// Generic Exceptions

class NetworkRequestFailedAuthException implements Exception {}

class GenericAuthException implements Exception {}
