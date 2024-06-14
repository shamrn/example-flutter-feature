import 'dart:async';

import 'package:arttek_mobile/common/providers/utils/base_state_notifier.dart';
import 'package:arttek_mobile/features/common/models/server_object.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_confirmation_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_errors.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_send_code_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_repository.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_state.dart';
import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExchangeBookingConfirmationProvider
    extends BaseStateNotifier<ExchangeBookingConfirmationState> {
  ExchangeBookingConfirmationProvider({
    @factoryParam required ExchangeBookingConfirmationArguments arguments,
    required ExchangeBookingConfirmationRepository confirmationRepository,
  })  : _arguments = arguments,
        _confirmationRepository = confirmationRepository,
        super(const ExchangeBookingConfirmationState());

  static const _validCodeLength = 6;

  final ExchangeBookingConfirmationArguments _arguments;
  final ExchangeBookingConfirmationRepository _confirmationRepository;

  Timer? _sendCodeTimer;

  @override
  Future<void> onInit() async {
    await sendCode();
  }

  @override
  void dispose() {
    _sendCodeTimer?.cancel();

    super.dispose();
  }

  void resetErrors() {
    state = state.copyWith(errors: null);
  }

  void handleOnFillCodeField(String value) {
    state = state.copyWith(
      isConfirmationButtonEnabled: value.length == _validCodeLength,
    );
  }

  Future<void> sendCode() async {
    state = state.copyWith(isResendCodeLoading: true);

    try {
      final sendCodeResponse = await _confirmationRepository.sendCode(
        ExchangeBookingConfirmationSendCodeRequest(
          quoteId: _arguments.quote.id,
        ),
      );

      final resendCodeCountdownSeconds =
          sendCodeResponse.nextTryDatetime.difference(clock.now()).inSeconds;

      await _runSendCodeCountdown(resendCodeCountdownSeconds);

      state = state.copyWith(
        isResendCodeLoading: false,
        isResendCodeEnabled: false,
        resendCodeCountdownSeconds: resendCodeCountdownSeconds,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: const ExchangeBookingConfirmationErrors(isServerError: true),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: const ExchangeBookingConfirmationErrors(isUnknownError: true),
      );
    }
  }

  Future<void> _runSendCodeCountdown(int resendCodeCountdownSeconds) async {
    _sendCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeSecond = timer.tick;

      state = state.copyWith(
        resendCodeCountdownSeconds: resendCodeCountdownSeconds - timeSecond,
      );

      if (timeSecond == resendCodeCountdownSeconds) {
        state = state.copyWith(isResendCodeEnabled: true);

        timer.cancel();
      }
    });
  }

  Future<void> confirmBooking(String confirmationCode) async {
    state = state.copyWith(isConfirmationButtonLoading: true);

    try {
      final confirmationRequest = _getExchangeConfirmationRequest();

      await _confirmationRepository.confirmBooking(confirmationRequest);

      state = state.copyWith(
        isConfirmationButtonLoading: false,
        isBookingSuccessful: true,
        isRedirectToExchangeMain: true,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isConfirmationButtonLoading: false,
        errors: const ExchangeBookingConfirmationErrors(isServerError: true),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isConfirmationButtonLoading: false,
        errors: const ExchangeBookingConfirmationErrors(isUnknownError: true),
      );
    }
  }

  ExchangeBookingConfirmationRequest _getExchangeConfirmationRequest() {
    return ExchangeBookingConfirmationRequest(
      id: _arguments.quote.id,
      version: _arguments.quote.version,
      status: ServerObject.fromItemUi(_arguments.quote.status),
      carrier: ServerObject.fromItemUi(_arguments.contractor),
      carrierContract: ServerObject.fromItemUi(_arguments.contract),
      driver: ServerObject.fromItemUi(_arguments.driver),
      truck: ServerObject.fromItemUi(_arguments.vehicle),
      trailer: ServerObject.fromItemUi(_arguments.trailer),
    );
  }
}
