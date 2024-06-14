import 'package:arttek_mobile/features/common/models/server_object.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_confirmation_request.freezed.dart';

part 'exchange_booking_confirmation_request.g.dart';

@freezed
class ExchangeBookingConfirmationRequest
    with _$ExchangeBookingConfirmationRequest {
  const factory ExchangeBookingConfirmationRequest({
    required int id,
    required int version,
    required ServerObject status,
    required ServerObject carrier,
    required ServerObject carrierContract,
    required ServerObject driver,
    required ServerObject truck,
    required ServerObject trailer,
  }) = _ExchangeBookingConfirmation;

  factory ExchangeBookingConfirmationRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ExchangeBookingConfirmationRequestFromJson(json);
}
