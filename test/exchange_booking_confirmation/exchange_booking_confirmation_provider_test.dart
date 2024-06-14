import 'dart:async';
import 'dart:io';

import 'package:arttek_mobile/features/common/models/item_ui.dart';
import 'package:arttek_mobile/features/common/models/server_object.dart';
import 'package:arttek_mobile/features/main/common/models/quote/quote_detail_ui.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_confirmation_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_errors.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_send_code_request.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/models/exchange_booking_confirmation_send_code_response.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_provider.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_repository.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_state.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/dio_test_helper.dart';
import 'exchange_booking_confirmation_provider_test.mocks.dart';

@GenerateMocks([ExchangeBookingConfirmationRepository])
void main() {
  final confirmationRepository = MockExchangeBookingConfirmationRepository();

  final ref = ProviderContainer();

  const sendCodeTimeSeconds = 2;
  const sendCodeDifferenceSeconds = 1;
  final fixedDateTime = DateTime(2001, 01, 01, 01, 01, sendCodeTimeSeconds);
  final nextSendCodeDateTime = DateTime(
    2001,
    01,
    01,
    01,
    01,
    sendCodeTimeSeconds + sendCodeDifferenceSeconds,
  );
  final clock = Clock.fixed(fixedDateTime);

  const codeValid = '123456';
  const codeInvalidFirst = '12345';
  const codeEmpty = '';

  const quote = QuoteDetailUi(
    id: 1,
    version: 2,
    status: ItemUi(id: 1, value: 'value'),
    carrierOrganization: ItemUi(id: 1, value: 'value'),
  );

  const arguments = ExchangeBookingConfirmationArguments(
    quote: quote,
    contractor: ItemUi(id: 1, value: 'value'),
    driver: ItemUi(id: 1, value: 'value'),
    vehicle: ItemUi(id: 1, value: 'value'),
    trailer: ItemUi(id: 1, value: 'value'),
    contract: ItemUi(id: 1, value: 'value'),
  );

  final sendCodeRequest = ExchangeBookingConfirmationSendCodeRequest(
    quoteId: quote.id,
  );

  final sendCodeResponse = ExchangeBookingConfirmationSendCodeResponse(
    nextTryDatetime: nextSendCodeDateTime,
  );

  final confirmationRequest = ExchangeBookingConfirmationRequest(
    id: quote.id,
    version: quote.version,
    status: const ServerObject(id: 1, value: 'value'),
    carrier: const ServerObject(id: 1, value: 'value'),
    carrierContract: const ServerObject(id: 1, value: 'value'),
    driver: const ServerObject(id: 1, value: 'value'),
    truck: const ServerObject(id: 1, value: 'value'),
    trailer: const ServerObject(id: 1, value: 'value'),
  );

  late StateNotifierProvider<ExchangeBookingConfirmationProvider,
      ExchangeBookingConfirmationState> provider;

  setUp(
    () {
      provider = StateNotifierProvider<ExchangeBookingConfirmationProvider,
          ExchangeBookingConfirmationState>(
        (ref) => withClock(
          clock,
          () => ExchangeBookingConfirmationProvider(
            arguments: arguments,
            confirmationRepository: confirmationRepository,
          ),
        ),
      );
    },
  );

  Future<void> expectOnSuccessLoaded() async {
    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );
  }

  test('Check default state values', () {
    const state = ExchangeBookingConfirmationState();

    expect(state.isResendCodeLoading, true);
    expect(state.isResendCodeEnabled, false);
    expect(state.isConfirmationButtonEnabled, false);
    expect(state.isConfirmationButtonLoading, false);
    expect(state.isCodeInvalid, false);
    expect(state.isBookingSuccessful, false);
    expect(state.isRedirectToExchangeMain, false);
    expect(state.resendCodeCountdownSeconds, null);
    expect(state.errors, null);
  });

  test('Check `onInit` method when successful execution', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
      (_) async => sendCodeResponse,
    );

    await expectOnSuccessLoaded();

    await Future.delayed(const Duration(seconds: 1), () {});

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        resendCodeCountdownSeconds: 0,
      ),
    );
  });

  test(
    'Check `onInit` method when dio exception ( the server returned a negative response )',
    () async {
      when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
        DioTestHelper.createException(
          statusCode: HttpStatus.internalServerError,
        ),
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingConfirmationState(
          isResendCodeLoading: false,
          isResendCodeEnabled: true,
          errors: ExchangeBookingConfirmationErrors(isServerError: true),
        ),
      );
    },
  );

  test('Check `onInit` method when base exception', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
      Exception(),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: ExchangeBookingConfirmationErrors(isUnknownError: true),
      ),
    );
  });

  test('Check `resetErrors` method ', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
      DioTestHelper.createException(
        statusCode: HttpStatus.internalServerError,
      ),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: ExchangeBookingConfirmationErrors(isServerError: true),
      ),
    );

    ref.read(provider.notifier).resetErrors();

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
      ),
    );
  });

  test('Check `handleOnFillCodeField` method', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
      (_) async => sendCodeResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).handleOnFillCodeField(codeInvalidFirst);

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );

    ref.read(provider.notifier).handleOnFillCodeField(codeValid);

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isConfirmationButtonEnabled: true,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );

    ref.read(provider.notifier).handleOnFillCodeField(codeEmpty);

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );
  });

  test('Check `sendCode` method when successful execution', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
      Exception(),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: ExchangeBookingConfirmationErrors(isUnknownError: true),
      ),
    );

    ref.read(provider.notifier).resetErrors();

    when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
      (_) async => sendCodeResponse,
    );

    unawaited(withClock(clock, () => ref.read(provider.notifier).sendCode()));

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(isResendCodeEnabled: true),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(isResendCodeEnabled: true),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );

    await Future.delayed(const Duration(seconds: 1), () {});

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        resendCodeCountdownSeconds: 0,
      ),
    );
  });

  test(
    'Check `sendCode` method when dio exception ( the server returned a negative response )',
    () async {
      when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
        DioTestHelper.createException(
          statusCode: HttpStatus.internalServerError,
        ),
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingConfirmationState(
          isResendCodeLoading: false,
          isResendCodeEnabled: true,
          errors: ExchangeBookingConfirmationErrors(isServerError: true),
        ),
      );

      ref.read(provider.notifier).resetErrors();

      unawaited(withClock(clock, () => ref.read(provider.notifier).sendCode()));

      await expectLater(
        ref.read(provider),
        const ExchangeBookingConfirmationState(
          isResendCodeLoading: false,
          isResendCodeEnabled: true,
          errors: ExchangeBookingConfirmationErrors(isServerError: true),
        ),
      );
    },
  );

  test('Check `sendCode` method when base exception', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenThrow(
      Exception(),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: ExchangeBookingConfirmationErrors(isUnknownError: true),
      ),
    );

    ref.read(provider.notifier).resetErrors();

    unawaited(withClock(clock, () => ref.read(provider.notifier).sendCode()));

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isResendCodeEnabled: true,
        errors: ExchangeBookingConfirmationErrors(isUnknownError: true),
      ),
    );
  });

  test('Check `confirmBooking` method when successful execution', () async {
    when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
      (_) async => sendCodeResponse,
    );

    await expectOnSuccessLoaded();

    unawaited(ref.read(provider.notifier).confirmBooking(codeValid));

    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isConfirmationButtonLoading: true,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingConfirmationState(
        isResendCodeLoading: false,
        isBookingSuccessful: true,
        isRedirectToExchangeMain: true,
        resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
      ),
    );

    verify(
      confirmationRepository.confirmBooking(confirmationRequest),
    ).called(1);
  });

  test(
    'Check `confirmBooking` method when dio exception ( the server returned a negative response )',
    () async {
      when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
        (_) async => sendCodeResponse,
      );
      when(confirmationRepository.confirmBooking(confirmationRequest))
          .thenThrow(
        DioTestHelper.createException(
          statusCode: HttpStatus.internalServerError,
        ),
      );

      await expectOnSuccessLoaded();

      unawaited(ref.read(provider.notifier).confirmBooking(codeValid));

      await expectLater(
        ref.read(provider),
        const ExchangeBookingConfirmationState(
          isResendCodeLoading: false,
          resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
          errors: ExchangeBookingConfirmationErrors(isServerError: true),
        ),
      );
    },
  );

  test(
    'Check `confirmBooking` method when base exception',
    () async {
      when(confirmationRepository.sendCode(sendCodeRequest)).thenAnswer(
        (_) async => sendCodeResponse,
      );
      when(confirmationRepository.confirmBooking(confirmationRequest))
          .thenThrow(Exception());

      await expectOnSuccessLoaded();

      unawaited(ref.read(provider.notifier).confirmBooking(codeValid));

      await expectLater(
        ref.read(provider),
        const ExchangeBookingConfirmationState(
          isResendCodeLoading: false,
          resendCodeCountdownSeconds: sendCodeDifferenceSeconds,
          errors: ExchangeBookingConfirmationErrors(isUnknownError: true),
        ),
      );
    },
  );
}
