class Flashcard {
  final String id;
  String front;
  String back;
  
  Flashcard({
    required this.id,
    required this.front,
    required this.back,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        front: json['front'] as String,
        back: json['back'] as String,
      );
}

class Deck {
  final String id;
  String title;
  String description;
  int colorHex;
  List<Flashcard> cards;

  Deck({
    required this.id,
    required this.title,
    this.description = '',
    required this.colorHex,
    List<Flashcard>? cards,
  }) : cards = cards ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'colorHex': colorHex,
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        colorHex: json['colorHex'] as int? ?? 0xFF7C3AED,
        cards: (json['cards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
