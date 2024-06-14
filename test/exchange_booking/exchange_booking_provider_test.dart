import 'dart:async';
import 'dart:io';

import 'package:arttek_mobile/features/common/helpers/user_id_helper.dart';
import 'package:arttek_mobile/features/common/models/item_ui.dart';
import 'package:arttek_mobile/features/common/models/server_object.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_contractor_data_request.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_contracts_request.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_vehicle_request.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_vehicle_response.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_vehicle_type.dart';
import 'package:arttek_mobile/features/main/common/models/options/options_vehicle_type_request.dart';
import 'package:arttek_mobile/features/main/common/models/quote/quote_detail_ui.dart';
import 'package:arttek_mobile/features/main/common/models/user/user_response.dart';
import 'package:arttek_mobile/features/main/common/repositories/options_repository.dart';
import 'package:arttek_mobile/features/main/common/repositories/user_repository.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_confirmation_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_errors.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_options_data.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/provider/exchange_booking_provider.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/provider/exchange_booking_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/dio_test_helper.dart';
import 'exchange_booking_provider_test.mocks.dart';

@GenerateMocks([OptionsRepository, UserIdHelper, UserRepository])
void main() {
  final optionsRepository = MockOptionsRepository();
  final userIdHelper = MockUserIdHelper();
  final userRepository = MockUserRepository();

  final ref = ProviderContainer();

  const quoteFirst = QuoteDetailUi(
    id: 1,
    version: 2,
    status: ItemUi(id: 1, value: 'value'),
    carrierOrganization: ItemUi(id: 1, value: 'value'),
  );
  const quoteSecond = QuoteDetailUi(
    id: 2,
    version: 2,
    status: ItemUi(id: 1, value: 'value'),
    carrierOrganization: null,
  );

  const argumentsWithCorrectQuote = ExchangeBookingArguments(quote: quoteFirst);
  const argumentsWithIncorrectQuote = ExchangeBookingArguments(
    quote: quoteSecond,
  );

  const contractorsResponse = [
    ServerObject(id: 1, value: 'value'),
    ServerObject(id: 2, value: 'value'),
  ];

  const contractorFirst = ItemUi(id: 1, value: 'value');

  const contractorsUi = [
    contractorFirst,
    ItemUi(id: 2, value: 'value'),
  ];

  const userId = 1;
  const userPhone = '79111111111';

  const userResponse = UserResponse(
    id: userId,
    viewName: 'viewName',
    phone: userPhone,
    roles: [],
  );

  const driversResponse = [
    ServerObject(id: 1, value: 'value'),
    ServerObject(id: 2, value: 'value'),
  ];

  const driversUi = [
    ItemUi(id: 1, value: 'value'),
    ItemUi(id: 2, value: 'value'),
  ];

  final vehiclesRequest = OptionsVehicleRequest(
    contractor: OptionsContractorDataRequest(id: contractorFirst.id),
    vtypes: const [
      OptionsVehicleTypeRequest(value: OptionsVehicleType.truck),
      OptionsVehicleTypeRequest(value: OptionsVehicleType.van),
      OptionsVehicleTypeRequest(value: OptionsVehicleType.bus),
    ],
  );

  const vehiclesResponse = OptionsVehicleResponse(
    data: [
      ServerObject(id: 1, value: 'value'),
      ServerObject(id: 2, value: 'value'),
    ],
  );

  const vehiclesUi = [
    ItemUi(id: 1, value: 'value'),
    ItemUi(id: 2, value: 'value'),
  ];

  final trailersRequest = OptionsVehicleRequest(
    contractor: OptionsContractorDataRequest(id: contractorFirst.id),
    vtypes: const [
      OptionsVehicleTypeRequest(value: OptionsVehicleType.trailer),
    ],
  );

  const trailersResponse = OptionsVehicleResponse(
    data: [
      ServerObject(id: 1, value: 'value'),
      ServerObject(id: 2, value: 'value'),
    ],
  );

  const trailersUi = [
    ItemUi(id: 1, value: 'value'),
    ItemUi(id: 2, value: 'value'),
  ];

  final contractsRequest = OptionsContractsRequest(
    contractorId: contractorFirst.id,
    organizationId: quoteFirst.carrierOrganization!.id,
  );

  const contractsResponse = [
    ServerObject(id: 1, value: 'value'),
    ServerObject(id: 2, value: 'value'),
  ];

  const contractsUi = [
    ItemUi(id: 1, value: 'value'),
    ItemUi(id: 2, value: 'value'),
  ];

  final exchangeBookingConfirmationArguments =
      ExchangeBookingConfirmationArguments(
    quote: quoteFirst,
    contractor: contractorFirst,
    driver: driversUi.first,
    vehicle: vehiclesUi.first,
    trailer: trailersUi.first,
    contract: contractsUi.first,
  );

  late StateNotifierProvider<ExchangeBookingProvider, ExchangeBookingState>
      provider;

  setUp(() {
    provider =
        StateNotifierProvider<ExchangeBookingProvider, ExchangeBookingState>(
      (ref) => ExchangeBookingProvider(
        arguments: argumentsWithCorrectQuote,
        optionsRepository: optionsRepository,
        userIdHelper: userIdHelper,
        userRepository: userRepository,
      ),
    );
  });

  Future<void> expectOnSuccessLoaded() async {
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        optionsData: ExchangeBookingOptionsData(contractors: contractorsUi),
        userPhone: userPhone,
      ),
    );
  }

  test('Check default state values', () {
    const state = ExchangeBookingState();

    expect(state.isLoading, true);
    expect(state.isOptionsByContractorLoading, false);
    expect(state.isContinueButtonEnabled, false);
    expect(state.optionsData, const ExchangeBookingOptionsData());
    expect(state.userPhone, null);
    expect(state.errors, null);
  });

  test('Check `onInit` method when quote is not correct', () async {
    provider =
        StateNotifierProvider<ExchangeBookingProvider, ExchangeBookingState>(
      (ref) => ExchangeBookingProvider(
        arguments: argumentsWithIncorrectQuote,
        optionsRepository: optionsRepository,
        userIdHelper: userIdHelper,
        userRepository: userRepository,
      ),
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        errors: ExchangeBookingErrors(isQuoteIncorrect: true),
      ),
    );
  });

  test('Check `onInit` method when successful execution', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();
  });

  test(
    'Check `onInit` method when dio exception ( the server returned a negative response )',
    () async {
      when(optionsRepository.getContractors()).thenThrow(
        DioTestHelper.createException(
          statusCode: HttpStatus.internalServerError,
        ),
      );
      when(userIdHelper.getIdOrLogout()).thenAnswer(
        (_) async => userId,
      );
      when(userRepository.getUser(userId)).thenAnswer(
        (_) async => userResponse,
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(),
      );
      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(),
      );
      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(),
      );
      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          errors: ExchangeBookingErrors(isServerError: true),
        ),
      );
    },
  );

  test('Check `onInit` method when base exception', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenThrow(Exception());

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        errors: ExchangeBookingErrors(isUnknownError: true),
      ),
    );
  });

  test('Check `resetErrors` method when base exception', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenThrow(Exception());

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );
    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(),
    );

    ref.read(provider.notifier).resetErrors();

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(isLoading: false),
    );
  });

  test(
      'Check `updateContractor` method conditions:'
      ' - successful execution'
      ' - contractor has not been previously selected', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );
    when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
      (_) async => driversResponse,
    );
    when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
      (_) async => vehiclesResponse,
    );
    when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
      (_) async => trailersResponse,
    );
    when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
      (_) async => contractsResponse,
    );

    await expectOnSuccessLoaded();

    unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

    const optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contractor: contractorFirst,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        isOptionsByContractorLoading: true,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    final updateOptionsData = optionsData.copyWith(
      drivers: driversUi,
      vehicles: vehiclesUi,
      trailers: trailersUi,
      contracts: contractsUi,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: updateOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test(
      'Check `updateContractor` method conditions:'
      ' - successful execution'
      ' -  contractor was previously selected', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );
    when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
      (_) async => driversResponse,
    );
    when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
      (_) async => vehiclesResponse,
    );
    when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
      (_) async => trailersResponse,
    );
    when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
      (_) async => contractsResponse,
    );

    await expectOnSuccessLoaded();

    unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

    const optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contractor: contractorFirst,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        isOptionsByContractorLoading: true,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    final updateOptionsData = optionsData.copyWith(
      drivers: driversUi,
      vehicles: vehiclesUi,
      trailers: trailersUi,
      contracts: contractsUi,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: updateOptionsData,
        userPhone: userPhone,
      ),
    );

    unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: updateOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test(
    'Check `updateContractor` method conditions:'
    ' - method when dio exception ( the server returned a negative response )'
    ' - contractor has not been previously selected',
    () async {
      when(optionsRepository.getContractors()).thenAnswer(
        (_) async => contractorsResponse,
      );
      when(userIdHelper.getIdOrLogout()).thenAnswer(
        (_) async => userId,
      );
      when(userRepository.getUser(userId)).thenAnswer(
        (_) async => userResponse,
      );
      when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
        (_) async => driversResponse,
      );
      when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
        (_) async => vehiclesResponse,
      );
      when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
        (_) async => trailersResponse,
      );
      when(optionsRepository.getContracts(contractsRequest)).thenThrow(
        DioTestHelper.createException(
          statusCode: HttpStatus.internalServerError,
        ),
      );

      await expectOnSuccessLoaded();

      unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

      const optionsData = ExchangeBookingOptionsData(
        contractors: contractorsUi,
        contractor: contractorFirst,
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          isOptionsByContractorLoading: true,
          optionsData: optionsData,
          userPhone: userPhone,
        ),
      );
      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          optionsData: optionsData,
          userPhone: userPhone,
          errors: ExchangeBookingErrors(isServerError: true),
        ),
      );
    },
  );

  test(
    'Check `updateContractor` method conditions:'
    ' - method when base exception'
    ' - contractor has not been previously selected',
    () async {
      when(optionsRepository.getContractors()).thenAnswer(
        (_) async => contractorsResponse,
      );
      when(userIdHelper.getIdOrLogout()).thenAnswer(
        (_) async => userId,
      );
      when(userRepository.getUser(userId)).thenAnswer(
        (_) async => userResponse,
      );
      when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
        (_) async => driversResponse,
      );
      when(optionsRepository.getVehicles(vehiclesRequest)).thenThrow(
        Exception(),
      );
      when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
        (_) async => trailersResponse,
      );
      when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
        (_) async => contractsResponse,
      );

      await expectOnSuccessLoaded();

      unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

      const optionsData = ExchangeBookingOptionsData(
        contractors: contractorsUi,
        contractor: contractorFirst,
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          isOptionsByContractorLoading: true,
          optionsData: optionsData,
          userPhone: userPhone,
        ),
      );
      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          optionsData: optionsData,
          userPhone: userPhone,
          errors: ExchangeBookingErrors(isUnknownError: true),
        ),
      );
    },
  );

  test('Check `updateDriver` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateDriver(driversUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      driver: driversUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `clearDriver` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateDriver(driversUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      driver: driversUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).clearDriver();

    const updatedOptionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        optionsData: updatedOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `updateVehicle` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateVehicle(vehiclesUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      vehicle: vehiclesUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `clearVehicle` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateVehicle(vehiclesUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      vehicle: vehiclesUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).clearVehicle();

    const updatedOptionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        optionsData: updatedOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `updateTrailer` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateTrailer(trailersUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      trailer: trailersUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `clearTrailer` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateTrailer(trailersUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      trailer: trailersUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).clearTrailer();

    const updatedOptionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        optionsData: updatedOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `updateContract` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateContract(contractsUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contract: contractsUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `clearContract` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );

    await expectOnSuccessLoaded();

    ref.read(provider.notifier).updateContract(contractsUi.first);

    final optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contract: contractsUi.first,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).clearContract();

    const updatedOptionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        optionsData: updatedOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `clearContractor` method', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );
    when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
      (_) async => driversResponse,
    );
    when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
      (_) async => vehiclesResponse,
    );
    when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
      (_) async => trailersResponse,
    );
    when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
      (_) async => contractsResponse,
    );

    await expectOnSuccessLoaded();

    unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

    const optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contractor: contractorFirst,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        isOptionsByContractorLoading: true,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    final updateOptionsData = optionsData.copyWith(
      drivers: driversUi,
      vehicles: vehiclesUi,
      trailers: trailersUi,
      contracts: contractsUi,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: updateOptionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).updateDriver(driversUi.first);
    ref.read(provider.notifier).updateVehicle(vehiclesUi.first);
    ref.read(provider.notifier).updateTrailer(trailersUi.first);
    ref.read(provider.notifier).updateContract(contractsUi.first);

    ref.read(provider.notifier).clearContractor();

    final clearOptionsData = optionsData.copyWith(
      drivers: [],
      vehicles: [],
      trailers: [],
      contracts: [],
      contractor: null,
      driver: null,
      vehicle: null,
      trailer: null,
      contract: null,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: clearOptionsData,
        userPhone: userPhone,
      ),
    );
  });

  test('Check `isContinueButtonEnabled` state', () async {
    when(optionsRepository.getContractors()).thenAnswer(
      (_) async => contractorsResponse,
    );
    when(userIdHelper.getIdOrLogout()).thenAnswer(
      (_) async => userId,
    );
    when(userRepository.getUser(userId)).thenAnswer(
      (_) async => userResponse,
    );
    when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
      (_) async => driversResponse,
    );
    when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
      (_) async => vehiclesResponse,
    );
    when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
      (_) async => trailersResponse,
    );
    when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
      (_) async => contractsResponse,
    );

    await expectOnSuccessLoaded();

    unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

    const optionsData = ExchangeBookingOptionsData(
      contractors: contractorsUi,
      contractor: contractorFirst,
    );

    await expectLater(
      ref.read(provider),
      const ExchangeBookingState(
        isLoading: false,
        isOptionsByContractorLoading: true,
        optionsData: optionsData,
        userPhone: userPhone,
      ),
    );

    final updateOptionsData = optionsData.copyWith(
      drivers: driversUi,
      vehicles: vehiclesUi,
      trailers: trailersUi,
      contracts: contractsUi,
    );

    await expectLater(
      ref.read(provider),
      ExchangeBookingState(
        isLoading: false,
        optionsData: updateOptionsData,
        userPhone: userPhone,
      ),
    );

    ref.read(provider.notifier).updateDriver(driversUi.first);
    ref.read(provider.notifier).updateVehicle(vehiclesUi.first);
    ref.read(provider.notifier).updateTrailer(trailersUi.first);
    ref.read(provider.notifier).updateContract(contractsUi.first);

    expect(ref.read(provider).isContinueButtonEnabled, true);

    ref.read(provider.notifier).clearDriver();
    expect(ref.read(provider).isContinueButtonEnabled, false);

    ref.read(provider.notifier).updateDriver(driversUi.first);
    ref.read(provider.notifier).clearVehicle();
    expect(ref.read(provider).isContinueButtonEnabled, false);

    ref.read(provider.notifier).updateVehicle(vehiclesUi.first);
    ref.read(provider.notifier).clearTrailer();
    expect(ref.read(provider).isContinueButtonEnabled, false);

    ref.read(provider.notifier).updateTrailer(trailersUi.first);
    ref.read(provider.notifier).clearContract();
    expect(ref.read(provider).isContinueButtonEnabled, false);

    ref.read(provider.notifier).updateContract(contractsUi.first);
    ref.read(provider.notifier).clearContractor();
    expect(ref.read(provider).isContinueButtonEnabled, false);
  });

  test(
    'Check `getExchangeBookingConfirmationArguments` method successful execution',
    () async {
      when(optionsRepository.getContractors()).thenAnswer(
        (_) async => contractorsResponse,
      );
      when(userIdHelper.getIdOrLogout()).thenAnswer(
        (_) async => userId,
      );
      when(userRepository.getUser(userId)).thenAnswer(
        (_) async => userResponse,
      );
      when(optionsRepository.getDrivers(contractorFirst.id)).thenAnswer(
        (_) async => driversResponse,
      );
      when(optionsRepository.getVehicles(vehiclesRequest)).thenAnswer(
        (_) async => vehiclesResponse,
      );
      when(optionsRepository.getVehicles(trailersRequest)).thenAnswer(
        (_) async => trailersResponse,
      );
      when(optionsRepository.getContracts(contractsRequest)).thenAnswer(
        (_) async => contractsResponse,
      );

      await expectOnSuccessLoaded();

      unawaited(ref.read(provider.notifier).updateContractor(contractorFirst));

      const optionsData = ExchangeBookingOptionsData(
        contractors: contractorsUi,
        contractor: contractorFirst,
      );

      await expectLater(
        ref.read(provider),
        const ExchangeBookingState(
          isLoading: false,
          isOptionsByContractorLoading: true,
          optionsData: optionsData,
          userPhone: userPhone,
        ),
      );

      final updateOptionsData = optionsData.copyWith(
        drivers: driversUi,
        vehicles: vehiclesUi,
        trailers: trailersUi,
        contracts: contractsUi,
      );

      await expectLater(
        ref.read(provider),
        ExchangeBookingState(
          isLoading: false,
          optionsData: updateOptionsData,
          userPhone: userPhone,
        ),
      );

      ref.read(provider.notifier).updateDriver(driversUi.first);
      ref.read(provider.notifier).updateVehicle(vehiclesUi.first);
      ref.read(provider.notifier).updateTrailer(trailersUi.first);
      ref.read(provider.notifier).updateContract(contractsUi.first);

      expect(
        ref.read(provider.notifier).getExchangeBookingConfirmationArguments(),
        exchangeBookingConfirmationArguments,
      );
    },
  );
}
