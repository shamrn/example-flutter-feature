import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_confirmation_errors.freezed.dart';

@freezed
class ExchangeBookingConfirmationErrors
    with _$ExchangeBookingConfirmationErrors {
  const factory ExchangeBookingConfirmationErrors({
    @Default(false) bool isServerError,
    @Default(false) bool isUnknownError,
  }) = _ExchangeBookingConfirmationErrors;
}
