import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_confirmation_send_code_response.freezed.dart';
part 'exchange_booking_confirmation_send_code_response.g.dart';

@freezed
class ExchangeBookingConfirmationSendCodeResponse
    with _$ExchangeBookingConfirmationSendCodeResponse {
  const factory ExchangeBookingConfirmationSendCodeResponse({
    required DateTime nextTryDatetime,
  }) = _ExchangeBookingConfirmationSendCodeResponse;

  factory ExchangeBookingConfirmationSendCodeResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ExchangeBookingConfirmationSendCodeResponseFromJson(json);
}
