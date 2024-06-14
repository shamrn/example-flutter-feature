import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_errors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_confirmation_state.freezed.dart';

@freezed
class ExchangeBookingConfirmationState with _$ExchangeBookingConfirmationState {
  const factory ExchangeBookingConfirmationState({
    @Default(true) bool isResendCodeLoading,
    @Default(false) bool isResendCodeEnabled,
    @Default(false) bool isConfirmationButtonEnabled,
    @Default(false) bool isConfirmationButtonLoading,
    @Default(false) bool isCodeInvalid,
    @Default(false) bool isBookingSuccessful,
    @Default(false) bool isRedirectToExchangeMain,
    int? resendCodeCountdownSeconds,
    ExchangeBookingConfirmationErrors? errors,
  }) = _ExchangeBookingConfirmationState;
}
