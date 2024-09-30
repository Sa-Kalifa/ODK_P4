import '../const/responsive.dart';
import '../widgets/activity_details_card.dart';
import '../widgets/bar_graph_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/graphique_card.dart';
import '../widgets/ddroite_widget.dart';
import 'package:flutter/material.dart';

// le widget de la barre de navigation

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Entete Recherche
            const HeaderWidget(),
            const SizedBox(height: 18),
            // les 4 card activite en haut
            const ActivityDetailsCard(),
            const SizedBox(height: 18),
            // Le Graphique
            const LineChartCard(),
            const SizedBox(height: 18),
            // Les barres de progression en bas au millieux
            const BarGraphCard(),
            const SizedBox(height: 18),
            if (Responsive.isTablet(context)) const DdroiteWidget(),
          ],
        ),
      ),
    );
  }
}
