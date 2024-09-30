class PageItems{
  List<PageInfo> items = [
    PageInfo(
        title: "Laboratory",
        descriptions: "A scientist in his laboratory is not a mere technician: he is also a child confronting natural phenomena that impress him as though they were fairy tales.",
        image: "lib/assets/images/intro2.png"),

    PageInfo(
        title: "Diagnosis",
        descriptions: "There is little you can do to stop a tornado, a hurricane, or a cancer diagnosis from changing your life in an instant.",
        image: "lib/assets/images/intro1.png"),

    PageInfo(
        title: "Chronic Diseases",
        descriptions: "Cancer taught my family that my mom is much stronger than we ever thought.",
        image: "lib/assets/images/intro4.png"),

    PageInfo(
        title: "Heart Diseases",
        descriptions: "A healthy heart is a key to happiness in life so put a stop to all of the problems related to your heart before it stops you.",
        image: "lib/assets/images/intro5.png"),

  ];
 }

 class PageInfo{
   final String title;
   final String descriptions;
   final String image;

   PageInfo({required this.title, required this.descriptions, required this.image});
 }