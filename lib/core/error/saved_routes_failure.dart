import 'package:route_flow/core/error/failures.dart';

abstract class SavedRoutesFailure extends Failure {
  const SavedRoutesFailure(super.message);
}

class SavedRoutesStorageFailure extends SavedRoutesFailure {
  const SavedRoutesStorageFailure() : super('storage_error');
}

class SavedRoutesAuthFailure extends SavedRoutesFailure {
  const SavedRoutesAuthFailure() : super('auth_error');
}

class UnexpectedSavedRoutesFailure extends SavedRoutesFailure {
  const UnexpectedSavedRoutesFailure([String? message]) : super(message ?? 'unexpected_storage_error');
}
