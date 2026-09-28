import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/data/models/service_items.dart';

import '../../../core/colors.dart';
import '../../../core/neumorphic.dart';
import '../controllers/more_services_controller.dart';

/// Grid of banking services, built from raised neumorphic containers.
class MoreServicesView extends GetView<MoreServicesController> {
  const MoreServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 18, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'More Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CustomColors.primaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Everything else in one place',
                  style: TextStyle(
                    fontSize: 13,
                    color: CustomColors.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              // Three across on a phone; the tiles are square so the raised
              // containers read as a neat block rather than stretched cards.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 130,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 0.92,
              ),
              itemCount: MoreServicesController.services.length,
              itemBuilder: (BuildContext context, int index) {
                final service = MoreServicesController.services[index];
                return _ServiceTile(
                  service: service,
                  onTap: () => controller.onServiceTap(service),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onTap});

  final ServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onTap,
      depth: 5,
      radius: NeumorphicTokens.radiusMedium,
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: <Widget>[
          if (service.isNew)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CustomColors.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              NeumorphicBox(
                shape: BoxShape.circle,
                depth: 4,
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  service.icon,
                  size: 22,
                  color: CustomColors.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  service.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
