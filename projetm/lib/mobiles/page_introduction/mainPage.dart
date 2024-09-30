import 'package:flutter/material.dart';
import 'package:projetm/mobiles/page_introduction/page1.dart';
import 'package:projetm/mobiles/page_introduction/page2.dart';
import 'package:projetm/mobiles/page_introduction/page3.dart';
import 'package:projetm/mobiles/page_introduction/page4.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../authentification/inscription.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  PageController pageController = PageController();
  String buttonText = "Skip"; // Initialiser le texte du bouton
  int currentPageIndex = 0;
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
                if (index == 3) {
                  isLastPage = true;
                  buttonText = "Démarrer";
                } else {
                  isLastPage = false;
                  buttonText = "Skip";
                }
              });
            },
            children: const [
              Page1(),
              Page2(),
              Page3(),
              Page4(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(),
                GestureDetector(
                  onTap: () {
                    if (isLastPage) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  Inscription(),
                        ),
                      );
                    } else {
                      pageController.jumpToPage(3); // Aller directement à la dernière page
                    }
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: pageController,
                  count: 4,
                  effect: const WormEffect(
                    activeDotColor: Color(0xFF914b14),
                  ),
                ),
                isLastPage
                    ? const SizedBox(width: 10)
                    : GestureDetector(
                  onTap: () {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  child: const Text(
                    "Suivant",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
