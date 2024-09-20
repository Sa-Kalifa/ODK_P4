import '../model/health_model.dart';

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
