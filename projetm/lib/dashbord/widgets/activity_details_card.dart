// Les deteils d'activite en haut


import '../const/responsive.dart';
import '../widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';

class ActivityDetailsCard extends StatelessWidget {
  const ActivityDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final healthDetails = HealthDetails();

    return GridView.builder(
      itemCount: healthDetails.healthData.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
        crossAxisSpacing: Responsive.isMobile(context) ? 12 : 15,
        mainAxisSpacing: 12.0,
      ),
      itemBuilder: (context, index) => CustomCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              healthDetails.healthData[index].icon,
              width: 30,
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 4),
              child: Text(
                healthDetails.healthData[index].value,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              healthDetails.healthData[index].title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// les classes

class HealthDetails {
  final healthData = const [
    HealthModel(
        icon: 'lib/assets/icons/burn.png', value: "305", title: "Calories burned"),
    HealthModel(
        icon: 'lib/assets/icons/steps.png', value: "10,983", title: "Steps"),
    HealthModel(
        icon: 'lib/assets/icons/distance.png', value: "7km", title: "Distance"),
    HealthModel(icon: 'lib/assets/icons/sleep.png', value: "7h48m", title: "Sleep"),
  ];
}

class HealthModel {
  final String icon;
  final String value;
  final String title;

  const HealthModel(
      {required this.icon, required this.value, required this.title});
}

