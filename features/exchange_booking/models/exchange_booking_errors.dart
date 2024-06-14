import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_errors.freezed.dart';

@freezed
class ExchangeBookingErrors with _$ExchangeBookingErrors {
  const factory ExchangeBookingErrors({
    @Default(false) bool isServerError,
    @Default(false) bool isUnknownError,
    @Default(false) bool isQuoteIncorrect,
  }) = _ExchangeBookingErrors;
}
