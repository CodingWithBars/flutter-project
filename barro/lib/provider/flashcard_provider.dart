import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../services/storage_service.dart';

class FlashcardProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoaded = false;

  List<Deck> get decks => List.unmodifiable(_decks);
  bool get isLoaded => _isLoaded;

  Future<void> loadDecks() async {
    if (_isLoaded) return;
    try {
      final data = await StorageService.loadDecks();
      if (data.isEmpty) {
        _decks = _getDummyDecks();
      } else {
        _decks = data.map((e) => Deck.fromJson(e)).toList();
      }
    } catch (e) {
      _decks = _getDummyDecks();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveDecks() async {
    final data = _decks.map((d) => d.toJson()).toList();
    await StorageService.saveDecks(data);
  }

  void addDeck(Deck deck) {
    _decks.add(deck);
    _saveDecks();
    notifyListeners();
  }

  void updateDeck(Deck deck) {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index != -1) {
      _decks[index] = deck;
      _saveDecks();
      notifyListeners();
    }
  }

  void deleteDeck(String id) {
    _decks.removeWhere((d) => d.id == id);
    _saveDecks();
    notifyListeners();
  }

  void addCardToDeck(String deckId, Flashcard card) {
    final deck = _decks.firstWhere((d) => d.id == deckId);
    deck.cards.add(card);
    _saveDecks();
    notifyListeners();
  }

  void removeCardFromDeck(String deckId, String cardId) {
    final deck = _decks.firstWhere((d) => d.id == deckId);
    deck.cards.removeWhere((c) => c.id == cardId);
    _saveDecks();
    notifyListeners();
  }

  List<Deck> _getDummyDecks() {
    return [
      Deck(
        id: 'd1',
        title: 'Computer Science 101',
        description: 'Basic terms and definitions',
        colorHex: 0xFF7C3AED,
        cards: [
          Flashcard(
            id: 'c1',
            front: 'What is an Algorithm?',
            back: 'A step-by-step set of instructions to solve a specific problem.',
          ),
          Flashcard(
            id: 'c2',
            front: 'What is a Compiler?',
            back: 'A program that converts source code into executable machine code.',
          ),
          Flashcard(
            id: 'c3',
            front: 'Explain OOP.',
            back: 'Object-Oriented Programming: A paradigm based on "objects" containing data and code.',
          ),
        ],
      ),
      Deck(
        id: 'd2',
        title: 'Spanish Vocabulary',
        description: 'Common conversational words',
        colorHex: 0xFF06B6D4,
        cards: [
          Flashcard(
            id: 'c4',
            front: 'Hola',
            back: 'Hello',
          ),
          Flashcard(
            id: 'c5',
            front: 'Gracias',
            back: 'Thank you',
          ),
          Flashcard(
            id: 'c6',
            front: 'Por favor',
            back: 'Please',
          ),
        ],
      ),
    ];
  }
}
