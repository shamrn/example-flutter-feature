import 'dart:async';

import 'package:arttek_mobile/common/providers/utils/base_state_notifier.dart';
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
import 'package:arttek_mobile/features/main/common/repositories/options_repository.dart';
import 'package:arttek_mobile/features/main/common/repositories/user_repository.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_confirmation_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_errors.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/models/exchange_booking_options_data.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/provider/exchange_booking_state.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExchangeBookingProvider extends BaseStateNotifier<ExchangeBookingState> {
  ExchangeBookingProvider({
    @factoryParam required ExchangeBookingArguments arguments,
    required OptionsRepository optionsRepository,
    required UserIdHelper userIdHelper,
    required UserRepository userRepository,
  })  : _arguments = arguments,
        _optionsRepository = optionsRepository,
        _userIdHelper = userIdHelper,
        _userRepository = userRepository,
        super(const ExchangeBookingState());

  final ExchangeBookingArguments _arguments;
  final OptionsRepository _optionsRepository;
  final UserIdHelper _userIdHelper;
  final UserRepository _userRepository;

  @override
  Future<void> onInit() async {
    try {
      final isQuoteValid = await _validationQuote();

      if (!isQuoteValid) {
        state = state.copyWith(
          isLoading: false,
          errors: const ExchangeBookingErrors(isQuoteIncorrect: true),
        );

        return;
      }

      late final List<ServerObject> contractorsResponse;
      late final String userPhone;

      await Future.wait<void>([
        (() async =>
            contractorsResponse = await _optionsRepository.getContractors())(),
        (() async => userPhone = await _getUserPhone())(),
      ]);

      final optionsData = state.optionsData.copyWith(
        contractors: contractorsResponse.map(ItemUi.fromResponse).toList(),
      );

      state = state.copyWith(
        isLoading: false,
        optionsData: optionsData,
        userPhone: userPhone,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isLoading: false,
        errors: const ExchangeBookingErrors(isServerError: true),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        errors: const ExchangeBookingErrors(isUnknownError: true),
      );
    }
  }

  Future<bool> _validationQuote() async {
    return _arguments.quote.carrierOrganization != null;
  }

  Future<String> _getUserPhone() async {
    final userId = await _userIdHelper.getIdOrLogout();
    final userResponse = await _userRepository.getUser(userId);

    return userResponse.phone;
  }

  void resetErrors() {
    state = state.copyWith(errors: null);
  }

  Future<void> updateContractor(ItemUi? contractor) async {
    if (contractor == state.optionsData.contractor || contractor == null) {
      return;
    }

    final optionsData = ExchangeBookingOptionsData(
      contractors: state.optionsData.contractors,
      contractor: contractor,
    );

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );

    await _loadOptionsByContractor(contractor);
  }

  Future<void> _loadOptionsByContractor(ItemUi contractor) async {
    state = state.copyWith(isOptionsByContractorLoading: true);

    try {
      late final List<ServerObject> driversResponse;
      late final OptionsVehicleResponse vehiclesResponse;
      late final OptionsVehicleResponse trailersResponse;
      late final List<ServerObject> contractsResponse;

      await Future.wait<void>([
        (() async => driversResponse = await _optionsRepository.getDrivers(
              contractor.id,
            ))(),
        (() async => vehiclesResponse = await _optionsRepository.getVehicles(
              _getOptionsVehiclesRequest(contractor),
            ))(),
        (() async => trailersResponse = await _optionsRepository.getVehicles(
              _getOptionsTrailersRequest(contractor),
            ))(),
        (() async => contractsResponse = await _optionsRepository.getContracts(
              _getContractsRequest(
                contractor: contractor,
                quote: _arguments.quote,
              ),
            ))(),
      ]);

      final optionsData = state.optionsData.copyWith(
        drivers: driversResponse.map(ItemUi.fromResponse).toList(),
        vehicles: vehiclesResponse.data.map(ItemUi.fromResponse).toList(),
        trailers: trailersResponse.data.map(ItemUi.fromResponse).toList(),
        contracts: contractsResponse.map(ItemUi.fromResponse).toList(),
      );

      state = state.copyWith(
        isOptionsByContractorLoading: false,
        optionsData: optionsData,
      );
    } on DioException catch (_) {
      state = state.copyWith(
        isOptionsByContractorLoading: false,
        errors: const ExchangeBookingErrors(isServerError: true),
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isOptionsByContractorLoading: false,
        errors: const ExchangeBookingErrors(isUnknownError: true),
      );
    }
  }

  OptionsVehicleRequest _getOptionsVehiclesRequest(ItemUi contractor) {
    return OptionsVehicleRequest(
      contractor: OptionsContractorDataRequest(id: contractor.id),
      vtypes: const [
        OptionsVehicleTypeRequest(value: OptionsVehicleType.truck),
        OptionsVehicleTypeRequest(value: OptionsVehicleType.van),
        OptionsVehicleTypeRequest(value: OptionsVehicleType.bus),
      ],
    );
  }

  OptionsVehicleRequest _getOptionsTrailersRequest(ItemUi contractor) {
    return OptionsVehicleRequest(
      contractor: OptionsContractorDataRequest(id: contractor.id),
      vtypes: const [
        OptionsVehicleTypeRequest(value: OptionsVehicleType.trailer),
      ],
    );
  }

  OptionsContractsRequest _getContractsRequest({
    required ItemUi contractor,
    required QuoteDetailUi quote,
  }) {
    return OptionsContractsRequest(
      contractorId: contractor.id,
      organizationId: quote.carrierOrganization!.id,
    );
  }

  void clearContractor() {
    final optionsData = ExchangeBookingOptionsData(
      contractors: state.optionsData.contractors,
    );

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void updateDriver(ItemUi? driver) {
    final optionsData = state.optionsData.copyWith(driver: driver);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void clearDriver() {
    final optionsData = state.optionsData.copyWith(driver: null);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void updateVehicle(ItemUi? vehicle) {
    final optionsData = state.optionsData.copyWith(vehicle: vehicle);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void clearVehicle() {
    final optionsData = state.optionsData.copyWith(vehicle: null);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void updateTrailer(ItemUi? trailer) {
    final optionsData = state.optionsData.copyWith(trailer: trailer);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void clearTrailer() {
    final optionsData = state.optionsData.copyWith(trailer: null);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void updateContract(ItemUi? contract) {
    final optionsData = state.optionsData.copyWith(contract: contract);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  void clearContract() {
    final optionsData = state.optionsData.copyWith(contract: null);

    state = state.copyWith(
      isContinueButtonEnabled: optionsData.isFieldsFilled,
      optionsData: optionsData,
    );
  }

  ExchangeBookingConfirmationArguments
      getExchangeBookingConfirmationArguments() {
    return ExchangeBookingConfirmationArguments(
      quote: _arguments.quote,
      contractor: state.optionsData.contractor!,
      driver: state.optionsData.driver!,
      vehicle: state.optionsData.vehicle!,
      trailer: state.optionsData.trailer!,
      contract: state.optionsData.contract!,
    );
  }
}
