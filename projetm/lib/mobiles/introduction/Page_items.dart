class PageItems{
  List<PageInfo> items = [
    PageInfo(
        title: "Echange",
        descriptions: "Un échange d’expériences n’est pas seulement une transmission de récits, c’est une invitation à explorer les mystères de notre vécu, comme un voyage au cœur de contes partagés, où chaque témoignage devient une étincelle d’émerveillement.",
        image: "lib/assets/images/intro2.png"),

    PageInfo(
        title: "L'entraide",
        descriptions: "Dans les moments d'adversité, l'entraide collective devient une force indomptable, transformant chaque obstacle en un tremplin vers la résilience, où ensemble, nous trouvons la lumière même dans les ténèbres.",
        image: "lib/assets/images/intro1.png"),

    PageInfo(
        title: "Déception",
        descriptions: "Dans le grand théâtre de la vie, la déception est souvent le drame inattendu qui nous invite à réévaluer nos désirs et à embrasser l'inattendu.",
        image: "lib/assets/images/intro4.png"),

    PageInfo(
        title: "Publie sans hésitation.",
        descriptions: "Racontez-nous vos expériences pour que nous puissions parler de vos défis et trouver ensemble des solutions.",
        image: "lib/assets/images/intro5.png"),

  ];
 }

 class PageInfo{
   final String title;
   final String descriptions;
   final String image;

   PageInfo({required this.title, required this.descriptions, required this.image});
 }