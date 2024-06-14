import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_confirmation_send_code_request.freezed.dart';
part 'exchange_booking_confirmation_send_code_request.g.dart';

@freezed
class ExchangeBookingConfirmationSendCodeRequest
    with _$ExchangeBookingConfirmationSendCodeRequest {
  const factory ExchangeBookingConfirmationSendCodeRequest({
    required int quoteId,
    @Default('BOOKING') String confirmationType,
  }) = _ExchangeBookingConfirmationSendCode;

  factory ExchangeBookingConfirmationSendCodeRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ExchangeBookingConfirmationSendCodeRequestFromJson(json);
}
