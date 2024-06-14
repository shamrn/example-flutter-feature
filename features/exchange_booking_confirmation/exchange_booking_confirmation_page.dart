import 'package:arttek_mobile/common/providers/utils/auto_dispose_consumer_state_with_provider.dart';
import 'package:arttek_mobile/common/routing/app_router.gr.dart';
import 'package:arttek_mobile/common/ui/app_colors.dart';
import 'package:arttek_mobile/common/ui/app_text_styles.dart';
import 'package:arttek_mobile/features/common/extensions/bottom_flash_bar_extension.dart';
import 'package:arttek_mobile/features/common/extensions/localization_extension.dart';
import 'package:arttek_mobile/features/common/extensions/router_extension.dart';
import 'package:arttek_mobile/features/common/widgets/app_pin_put.dart';
import 'package:arttek_mobile/features/common/widgets/app_top_bar.dart';
import 'package:arttek_mobile/features/common/widgets/outline_solid_button.dart';
import 'package:arttek_mobile/features/common/widgets/resend_code.dart';
import 'package:arttek_mobile/features/common/widgets/scalable_opacity_tap.dart';
import 'package:arttek_mobile/features/main/exchange/common/arguments/exchange_booking_confirmation_arguments.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_provider.dart';
import 'package:arttek_mobile/features/main/exchange/exchange_booking_confirmation/provider/exchange_booking_confirmation_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

@RoutePage()
class ExchangeBookingConfirmationPage extends ConsumerStatefulWidget {
  const ExchangeBookingConfirmationPage({
    required ExchangeBookingConfirmationArguments arguments,
    super.key,
  }) : _arguments = arguments;

  final ExchangeBookingConfirmationArguments _arguments;

  @override
  ConsumerState<ExchangeBookingConfirmationPage> createState() =>
      // ignore: no_logic_in_create_state
      _ExchangeBookingConfirmationState(_arguments);
}

class _ExchangeBookingConfirmationState
    extends AutoDisposeConsumerStateWithProvider<
        ExchangeBookingConfirmationProvider,
        ExchangeBookingConfirmationState,
        ExchangeBookingConfirmationPage> {
  _ExchangeBookingConfirmationState(
    ExchangeBookingConfirmationArguments arguments,
  ) : super(param1: arguments);

  late final TextEditingController _codeTextEditingController;

  @override
  void initState() {
    super.initState();

    _codeTextEditingController = TextEditingController()
      ..addListener(_codeTextEditingControllerListener);
  }

  @override
  void dispose() {
    _codeTextEditingController.dispose();

    super.dispose();
  }

  void _codeTextEditingControllerListener() {
    ref.read(provider.notifier).handleOnFillCodeField(
          _codeTextEditingController.text,
        );
  }

  void _errorsListener(
    ExchangeBookingConfirmationState? previous,
    ExchangeBookingConfirmationState next,
  ) {
    final errors = next.errors;

    if (errors != null) {
      if (errors.isUnknownError) context.bottomFlashBars.showUnknownError();
      if (errors.isServerError) context.bottomFlashBars.showServerError();

      ref.read(provider.notifier).resetErrors();
    }
  }

  void _redirectListener(
    ExchangeBookingConfirmationState? previous,
    ExchangeBookingConfirmationState next,
  ) {
    if (next.isRedirectToExchangeMain) {
      context.router.popUntilNamedWithResult(
        ExchangeMainRoute.name,
        next.isBookingSuccessful,
      );
    }
  }

  void _onTapResendCode() {
    ref.read(provider.notifier).sendCode();
  }

  void _onTapConfirmation() {
    ref.read(provider.notifier).confirmBooking(_codeTextEditingController.text);
  }

  void _onTapCancel() {
    context.router.popUntilRouteWithName(ExchangeMainRoute.name);
  }

  Widget _buildBody() {
    final state = ref.watch(provider);

    return Column(
      children: [
        Text(
          context.locale.exchangeBookingConfirmationSendCodeHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.interRegular.copyWith(
            color: AppColors.textFourth,
          ),
        ),
        SizedBox(height: 16.h),
        AppPinPut(textEditingController: _codeTextEditingController),
        SizedBox(height: 16.h),
        ResendCode(
          isLoading: state.isResendCodeLoading,
          isResendEnable: state.isResendCodeEnabled,
          onTap: _onTapResendCode,
          countdownSeconds: state.resendCodeCountdownSeconds,
        ),
        const Spacer(),
        Text(
          context.locale.exchangeBookingConfirmationConfirmationHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.interRegular.copyWith(
            color: AppColors.textFourth,
          ),
        ),
        SizedBox(height: 8.h),
        OutlineSolidButton(
          onTap: _onTapConfirmation,
          title:
              context.locale.exchangeBookingConfirmationConfirmationButtonTitle,
          isEnabled: state.isConfirmationButtonEnabled,
          isLoading: state.isConfirmationButtonLoading,
        ),
        SizedBox(height: 16.h),
        ScalableOpacityTap(
          onTap: _onTapCancel,
          child: Text(
            context.locale.exchangeBookingConfirmationCancelButtonTitle,
            style: AppTextStyles.interMedium.copyWith(
              color: AppColors.textThird,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(provider, _errorsListener)
      ..listen(provider, _redirectListener);

    return Scaffold(
      appBar: AppTopBar(
        title: context.locale.exchangeBookingConfirmationTopBarTitle,
      ),
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
