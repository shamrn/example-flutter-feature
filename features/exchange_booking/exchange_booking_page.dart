import 'package:arttek_mobile/common/providers/utils/auto_dispose_consumer_state_with_provider.dart';
import 'package:arttek_mobile/common/routing/app_router.gr.dart';
import 'package:arttek_mobile/common/ui/app_colors.dart';
import 'package:arttek_mobile/common/ui/app_text_styles.dart';
import 'package:arttek_mobile/features/common/extensions/bottom_flash_bar_extension.dart';
import 'package:arttek_mobile/features/common/extensions/localization_extension.dart';
import 'package:arttek_mobile/features/common/models/item_ui.dart';
import 'package:arttek_mobile/features/common/widgets/animated_fade.dart';
import 'package:arttek_mobile/features/common/widgets/app_top_bar.dart';
import 'package:arttek_mobile/features/common/widgets/field_box_shimmer.dart';
import 'package:arttek_mobile/features/common/widgets/outline_solid_button.dart';
import 'package:arttek_mobile/features/common/widgets/single_searchable_dropdown_field.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/provider/exchange_booking_provider.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/provider/exchange_booking_state.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking/widgets/exchange_booking_shimmer.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class ExchangeBookingPage extends ConsumerStatefulWidget {
  const ExchangeBookingPage({
    required ExchangeBookingArguments arguments,
    super.key,
  }) : _arguments = arguments;

  final ExchangeBookingArguments _arguments;

  @override
  ConsumerState<ExchangeBookingPage> createState() =>
      // ignore: no_logic_in_create_state
      _ExchangeBookingState(_arguments);
}

class _ExchangeBookingState extends AutoDisposeConsumerStateWithProvider<
    ExchangeBookingProvider, ExchangeBookingState, ExchangeBookingPage> {
  _ExchangeBookingState(
    ExchangeBookingArguments arguments,
  ) : super(param1: arguments);

  void _errorsListener(
    ExchangeBookingState? previous,
    ExchangeBookingState next,
  ) {
    final errors = next.errors;

    if (errors != null) {
      if (errors.isUnknownError) context.bottomFlashBars.showUnknownError();
      if (errors.isServerError) context.bottomFlashBars.showServerError();
      if (errors.isQuoteIncorrect) {
        context.bottomFlashBars.showInformation(
          title: context.locale.exchangeBookingQuoteIncorrectBarTitle,
          description:
              context.locale.exchangeBookingQuoteIncorrectBarDescription,
        );
      }

      ref.read(provider.notifier).resetErrors();
    }
  }

  String _onGetItemLabel(ItemUi item) {
    return item.value;
  }

  void _onChangedContractor(ItemUi? contractor) {
    ref.read(provider.notifier).updateContractor(contractor);
  }

  void _onClearContractor() {
    ref.read(provider.notifier).clearContractor();
  }

  void _onChangedDriver(ItemUi? driver) {
    ref.read(provider.notifier).updateDriver(driver);
  }

  void _onClearDriver() {
    ref.read(provider.notifier).clearDriver();
  }

  void _onChangedVehicle(ItemUi? vehicle) {
    ref.read(provider.notifier).updateVehicle(vehicle);
  }

  void _onClearVehicle() {
    ref.read(provider.notifier).clearVehicle();
  }

  void _onChangedTrailer(ItemUi? trailer) {
    ref.read(provider.notifier).updateTrailer(trailer);
  }

  void _onClearTrailer() {
    ref.read(provider.notifier).clearTrailer();
  }

  void _onChangedContract(ItemUi? contract) {
    ref.read(provider.notifier).updateContract(contract);
  }

  void _onClearContract() {
    ref.read(provider.notifier).clearContract();
  }

  void _onTapContinue() {
    final exchangeBookingConfirmationArguments =
        ref.read(provider.notifier).getExchangeBookingConfirmationArguments();

    context.router.push(
      ExchangeBookingConfirmationRoute(
        arguments: exchangeBookingConfirmationArguments,
      ),
    );
  }

  Widget _buildPageContent(ExchangeBookingState state) {
    return Column(
      children: [
        SingleSearchableDropdownField<ItemUi>(
          title: context.locale.exchangeBookingContractorFieldTitle,
          hintText: context.locale.optionFieldHint,
          items: state.optionsData.contractors,
          value: state.optionsData.contractor,
          onChanged: _onChangedContractor,
          onGetItemLabel: _onGetItemLabel,
          onClear: _onClearContractor,
        ),
        SizedBox(height: 12.h),
        AnimatedFade(
          fadeState: state.isOptionsByContractorLoading
              ? AnimatedFadeState.showFirst
              : AnimatedFadeState.showSecond,
          firstChild: const FieldBoxShimmer(),
          secondChild: SingleSearchableDropdownField<ItemUi>(
            title: context.locale.exchangeBookingDriverFieldTitle,
            hintText: context.locale.optionFieldHint,
            items: state.optionsData.drivers,
            value: state.optionsData.driver,
            onChanged: _onChangedDriver,
            onGetItemLabel: _onGetItemLabel,
            onClear: _onClearDriver,
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedFade(
          fadeState: state.isOptionsByContractorLoading
              ? AnimatedFadeState.showFirst
              : AnimatedFadeState.showSecond,
          firstChild: const FieldBoxShimmer(),
          secondChild: SingleSearchableDropdownField<ItemUi>(
            title: context.locale.exchangeBookingVehicleFieldTitle,
            hintText: context.locale.optionFieldHint,
            items: state.optionsData.vehicles,
            value: state.optionsData.vehicle,
            onChanged: _onChangedVehicle,
            onGetItemLabel: _onGetItemLabel,
            onClear: _onClearVehicle,
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedFade(
          fadeState: state.isOptionsByContractorLoading
              ? AnimatedFadeState.showFirst
              : AnimatedFadeState.showSecond,
          firstChild: const FieldBoxShimmer(),
          secondChild: SingleSearchableDropdownField<ItemUi>(
            title: context.locale.exchangeBookingTrailerFieldTitle,
            hintText: context.locale.optionFieldHint,
            items: state.optionsData.trailers,
            value: state.optionsData.trailer,
            onChanged: _onChangedTrailer,
            onGetItemLabel: _onGetItemLabel,
            onClear: _onClearTrailer,
          ),
        ),
        SizedBox(height: 12.h),
        AnimatedFade(
          fadeState: state.isOptionsByContractorLoading
              ? AnimatedFadeState.showFirst
              : AnimatedFadeState.showSecond,
          firstChild: const FieldBoxShimmer(),
          secondChild: SingleSearchableDropdownField<ItemUi>(
            title: context.locale.exchangeBookingContractFieldTitle,
            hintText: context.locale.optionFieldHint,
            items: state.optionsData.contracts,
            value: state.optionsData.contract,
            onChanged: _onChangedContract,
            onGetItemLabel: _onGetItemLabel,
            onClear: _onClearContract,
          ),
        ),
        const Spacer(),
        OutlineSolidButton(
          onTap: _onTapContinue,
          title: context.locale.exchangeBookingContinueButtonLabel,
          isEnabled: state.isContinueButtonEnabled,
        ),
        SizedBox(height: 8.h),
        Text(
          context.locale.exchangeBookingInformation(
            state.userPhone ?? context.locale.dashSymbol,
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.interRegular.copyWith(
            fontSize: 14.sp,
            color: AppColors.textSecond,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return AnimatedFade(
      fadeState: state.isLoading
          ? AnimatedFadeState.showFirst
          : AnimatedFadeState.showSecond,
      firstChild: const ExchangeBookingShimmer(),
      secondChild: _buildPageContent(state),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(provider, _errorsListener);

    return Scaffold(
      appBar: AppTopBar(title: context.locale.exchangeBookingTopBarTitle),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 20.h,
            left: 15.w,
            right: 15.w,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(child: _buildBody()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
