import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_model.dart';
import '../provider/flashcard_provider.dart';
import '../widgets/flip_card.dart';

// ─────────────────────────────────────────────
// Deck List Screen
// ─────────────────────────────────────────────
class FlashcardDeckScreen extends StatelessWidget {
  const FlashcardDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, _) {
          if (provider.decks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.style_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('No flashcard decks yet',
                      style: TextStyle(color: Colors.white54, fontSize: 16)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showDeckDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Deck'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: provider.decks.length,
            itemBuilder: (context, index) {
              final deck = provider.decks[index];
              return _buildDeckCard(context, deck, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_deck',
        onPressed: () => _showDeckDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Deck'),
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, Deck deck, FlashcardProvider provider) {
    final color = Color(deck.colorHex);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DeckDetailScreen(deck: deck)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.style_rounded, color: color, size: 20),
                ),
                // Context menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 18),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showDeckDialog(context, deck: deck);
                    } else if (value == 'delete') {
                      _confirmDeleteDeck(context, deck, provider);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Edit')])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.redAccent))])),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              deck.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                deck.description,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Text(
              '${deck.cards.length} card${deck.cards.length != 1 ? 's' : ''}',
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeckDialog(BuildContext context, {Deck? deck}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeckFormSheet(deck: deck),
    );
  }

  void _confirmDeleteDeck(BuildContext context, Deck deck, FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.title}"? This will remove all ${deck.cards.length} cards.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.deleteDeck(deck.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Deck Form (Add / Edit)
// ─────────────────────────────────────────────
class _DeckFormSheet extends StatefulWidget {
  final Deck? deck;
  const _DeckFormSheet({this.deck});

  @override
  State<_DeckFormSheet> createState() => _DeckFormSheetState();
}

class _DeckFormSheetState extends State<_DeckFormSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late int _colorHex;

  static const List<int> _palette = [
    0xFF7C3AED, 0xFF06B6D4, 0xFF10B981, 0xFFF59E0B, 0xFFEC4899, 0xFFEF4444, 0xFF3B82F6,
  ];

  bool get isEditing => widget.deck != null;

  @override
  void initState() {
    super.initState();
    if (widget.deck != null) {
      _titleController.text = widget.deck!.title;
      _descController.text = widget.deck!.description;
      _colorHex = widget.deck!.colorHex;
    } else {
      _colorHex = _palette[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FlashcardProvider>();

    if (isEditing) {
      final updated = Deck(
        id: widget.deck!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        colorHex: _colorHex,
        cards: List.from(widget.deck!.cards),
      );
      provider.updateDeck(updated);
    } else {
      final newDeck = Deck(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        colorHex: _colorHex,
      );
      provider.addDeck(newDeck);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(isEditing ? 'Edit Deck' : 'New Deck',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Deck Title *',
                  hintText: 'e.g. Biology Chapter 3',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              const Text('Color', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _palette.map((color) {
                  final isSelected = _colorHex == color;
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = color),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: isSelected ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4))] : null,
                      ),
                      child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(isEditing ? 'Save Changes' : 'Create Deck',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Deck Detail Screen (shows cards, manage them)
// ─────────────────────────────────────────────
class DeckDetailScreen extends StatelessWidget {
  final Deck deck;
  const DeckDetailScreen({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final color = Color(deck.colorHex);

    return Consumer<FlashcardProvider>(
      builder: (context, provider, _) {
        // Always get the live deck from the provider so changes reflect immediately
        final liveDeck = provider.decks.firstWhere(
          (d) => d.id == deck.id,
          orElse: () => deck,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(liveDeck.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (liveDeck.cards.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudyScreen(deck: liveDeck)),
                    );
                  },
                  icon: Icon(Icons.play_arrow_rounded, color: color),
                  label: Text('Study', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: liveDeck.cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card_off_rounded, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text('No cards yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _showCardDialog(context, liveDeck),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add First Card'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: liveDeck.cards.length,
                  itemBuilder: (context, index) {
                    final card = liveDeck.cards[index];
                    return _buildCardTile(context, liveDeck, card, color, provider);
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_card',
            onPressed: () => _showCardDialog(context, liveDeck),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Card'),
            backgroundColor: color,
          ),
        );
      },
    );
  }

  Widget _buildCardTile(BuildContext context, Deck liveDeck, Flashcard card, Color color, FlashcardProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 4, height: 44,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        title: Text(card.front, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(card.back, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white38),
              onPressed: () => _showCardDialog(context, liveDeck, card: card),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.white38),
              onPressed: () => _confirmDeleteCard(context, liveDeck, card, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDialog(BuildContext context, Deck liveDeck, {Flashcard? card}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardFormSheet(deck: liveDeck, card: card),
    );
  }

  void _confirmDeleteCard(BuildContext context, Deck liveDeck, Flashcard card, FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Delete the card "${card.front}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.removeCardFromDeck(liveDeck.id, card.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card Form (Add / Edit)
// ─────────────────────────────────────────────
class _CardFormSheet extends StatefulWidget {
  final Deck deck;
  final Flashcard? card;
  const _CardFormSheet({required this.deck, this.card});

  @override
  State<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<_CardFormSheet> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _frontController.text = widget.card!.front;
      _backController.text = widget.card!.back;
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FlashcardProvider>();

    if (isEditing) {
      // Rebuild the full deck with updated card
      final updatedCards = widget.deck.cards.map((c) {
        if (c.id == widget.card!.id) {
          return Flashcard(
            id: c.id,
            front: _frontController.text.trim(),
            back: _backController.text.trim(),
          );
        }
        return c;
      }).toList();

      final updatedDeck = Deck(
        id: widget.deck.id,
        title: widget.deck.title,
        description: widget.deck.description,
        colorHex: widget.deck.colorHex,
        cards: updatedCards,
      );
      provider.updateDeck(updatedDeck);
    } else {
      final newCard = Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        front: _frontController.text.trim(),
        back: _backController.text.trim(),
      );
      provider.addCardToDeck(widget.deck.id, newCard);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.deck.colorHex);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.style_rounded, color: color),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Edit Card' : 'New Card',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _frontController,
                decoration: const InputDecoration(
                  labelText: 'Front (Question / Term) *',
                  hintText: 'e.g. What is photosynthesis?',
                  prefixIcon: Icon(Icons.help_outline_rounded),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Front side cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _backController,
                decoration: const InputDecoration(
                  labelText: 'Back (Answer / Definition) *',
                  hintText: 'e.g. The process by which plants make food...',
                  prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Back side cannot be empty' : null,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(isEditing ? 'Save Card' : 'Add Card',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Study Screen (flip cards)
// ─────────────────────────────────────────────
class StudyScreen extends StatefulWidget {
  final Deck deck;
  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;

  void _next() {
    if (_currentIndex < widget.deck.cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deck Complete! 🎉'),
        content: Text('You reviewed all ${widget.deck.cards.length} cards in "${widget.deck.title}".'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); setState(() => _currentIndex = 0); }, child: const Text('Restart')),
          FilledButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.deck.cards[_currentIndex];
    final progress = (_currentIndex + 1) / widget.deck.cards.length;
    final color = Color(widget.deck.colorHex);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.deck.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              '${_currentIndex + 1} / ${widget.deck.cards.length}',
              style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 380,
                  child: FlipCard(
                    key: ValueKey(card.id),
                    front: _buildSide(card.front, 'FRONT', false, color),
                    back: _buildSide(card.back, 'BACK', true, color),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? _prev : null,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.03),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                Text('Tap card to flip',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13)),
                IconButton(
                  onPressed: _next,
                  icon: Icon(_currentIndex == widget.deck.cards.length - 1
                      ? Icons.check_rounded
                      : Icons.arrow_forward_ios_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSide(String text, String label, bool isBack, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: isBack ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isBack ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20, left: 24,
            child: Text(label,
              style: TextStyle(
                color: isBack ? color : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
