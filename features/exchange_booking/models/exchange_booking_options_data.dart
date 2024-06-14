import 'package:arttek_mobile/features/common/models/item_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_booking_options_data.freezed.dart';

@freezed
class ExchangeBookingOptionsData with _$ExchangeBookingOptionsData {
  const factory ExchangeBookingOptionsData({
    @Default([]) List<ItemUi> contractors,
    @Default([]) List<ItemUi> drivers,
    @Default([]) List<ItemUi> vehicles,
    @Default([]) List<ItemUi> trailers,
    @Default([]) List<ItemUi> contracts,
    ItemUi? contractor,
    ItemUi? driver,
    ItemUi? vehicle,
    ItemUi? trailer,
    ItemUi? contract,
  }) = _ExchangeBookingOptionsData;

  const ExchangeBookingOptionsData._();

  bool get isFieldsFilled =>
      contractor != null &&
      driver != null &&
      vehicle != null &&
      trailer != null &&
      contract != null;
}
