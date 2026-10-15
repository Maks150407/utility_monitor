import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/utility_summary_card.dart';
import '../../core/widgets/cost_summary_card.dart';
import '../../core/widgets/consumption_dynamics_card.dart';
import '../../core/widgets/reading_list_item.dart';
import '../../models/meter_reading.dart';
import '../../models/utility_type.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAllReadings;
  final List<MeterReading> readings;

  const HomeScreen({
    super.key,
    this.onViewAllReadings,
    required this.readings,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Current month summary
              const Text(
                'Поточний місяць',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16.0),

              // 3 Utility summary cards (Water, Electricity, Gas)
              // Hardcoded monthly consumption values and costs based on tariffs
              const Row(
                children: [
                  UtilitySummaryCard(
                    type: UtilityType.water,
                    consumptionText: '12.4 м³',
                    costText: '376.71 ₴',
                    tariffText: '30.38 ₴/м³',
                  ),
                  SizedBox(width: 14.0),
                  UtilitySummaryCard(
                    type: UtilityType.electricity,
                    consumptionText: '187\nкВт·год',
                    costText: '807.84 ₴',
                    tariffText: '4.32 ₴/кВт·год',
                  ),
                  SizedBox(width: 14.0),
                  UtilitySummaryCard(
                    type: UtilityType.gas,
                    consumptionText: '58 м³',
                    costText: '461.68 ₴',
                    tariffText: '7.96 ₴/м³',
                  ),
                ],
              ),
              const SizedBox(height: 28.0),

              // Responsive layout: Desktop 2-column vs Mobile 1-column
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Recent readings (6 items)
                    Expanded(
                      flex: 3,
                      child: _buildRecentReadingsSection(context, maxItems: 6),
                    ),
                    const SizedBox(width: 24.0),
                    // Right column: Monthly cost & dynamics cards
                    const Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          CostSummaryCard(
                            amount: '1 284 ₴',
                            trendText: '6% порівняно з серпнем',
                          ),
                          SizedBox(height: 24.0),
                          ConsumptionDynamicsCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentReadingsSection(context, maxItems: 3),
                    const SizedBox(height: 24.0),
                    const CostSummaryCard(
                      amount: '1 284 ₴',
                      trendText: '6% порівняно з серпнем',
                    ),
                    const SizedBox(height: 24.0),
                    const ConsumptionDynamicsCard(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentReadingsSection(BuildContext context, {required int maxItems}) {
    final recentList = readings.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Останні показники',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: onViewAllReadings,
              child: const Row(
                children: [
                  Text(
                    'Усі',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_forward,
                    size: 16.0,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppStyles.radiusXl,
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: AppStyles.softShadow,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) {
              final reading = recentList[index];
              return ReadingListItem(
                reading: reading,
                showActions: false,
              );
            },
          ),
        ),
      ],
    );
  }
}
