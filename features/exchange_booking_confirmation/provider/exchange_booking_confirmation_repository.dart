import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_send_code_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_send_code_response.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'exchange_booking_confirmation_repository.g.dart';

@RestApi()
@injectable
abstract class ExchangeBookingConfirmationRepository {
  @factoryMethod
  factory ExchangeBookingConfirmationRepository(Dio dio) =>
      _ExchangeBookingConfirmationRepository(dio);

  @POST('----')
  Future<ExchangeBookingConfirmationSendCodeResponse> sendCode(
    @Body() ExchangeBookingConfirmationSendCodeRequest body,
  );

  @POST('----')
  Future<void> confirmBooking(@Body() ExchangeBookingConfirmationRequest body);
}
