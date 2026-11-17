class DestinoModel {
  final String nome;
  final String img;
  final int valord; // valor da diária
  final int valorp; // valor por pessoa

  const DestinoModel(this.nome, this.img, this.valord, this.valorp);

  static const List<DestinoModel> destinos = [
    DestinoModel('Angra dos Reis', 'assets/angra-dos-reis.jpg', 384, 70),
    DestinoModel('Jericoacoara', 'assets/jericoacoara.jpg', 571, 75),
    DestinoModel('Arraial do Cabo', 'assets/arraial-do-cabo.jpg', 534, 65),
    DestinoModel('Florianópolis', 'assets/florianopolis.jpg', 348, 85),
    DestinoModel('Madri', 'assets/madri.jpg', 401, 85),
    DestinoModel('Paris', 'assets/paris.jpg', 546, 95),
    DestinoModel('Orlando', 'assets/orlando.jpg', 616, 105),
    DestinoModel('Las Vegas', 'assets/las-vegas.jpg', 504, 110),
    DestinoModel('Roma', 'assets/roma.jpg', 478, 85),
    DestinoModel('Chile', 'assets/chile.jpg', 446, 95),
  ];
}