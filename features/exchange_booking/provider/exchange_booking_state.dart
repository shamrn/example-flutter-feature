import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_errors.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_options_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_state.freezed.dart';

@freezed
class ExchangeBookingState with _$ExchangeBookingState {
  const factory ExchangeBookingState({
    @Default(true) bool isLoading,
    @Default(false) bool isOptionsByContractorLoading,
    @Default(false) bool isContinueButtonEnabled,
    @Default(ExchangeBookingOptionsData())
    ExchangeBookingOptionsData optionsData,
    String? userPhone,
    ExchangeBookingErrors? errors,
  }) = _ExchangeBookingState;
}
