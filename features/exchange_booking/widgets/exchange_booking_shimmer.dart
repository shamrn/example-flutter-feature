import 'package:arttek_mobile/features/common/widgets/field_box_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExchangeBookingShimmer extends StatelessWidget {
  const ExchangeBookingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: const FieldBoxShimmer(),
        ),
      ),
    );
  }
}
