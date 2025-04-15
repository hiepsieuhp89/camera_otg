import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/text_expansion.dart';
import 'package:kyoryo/src/providers/text_expansions.provider.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';

// Helper class for word info
class WordInfo {
  final String word;
  final int start;
  final int end;
  
  WordInfo({required this.word, required this.start, required this.end});
}

class TextExpansionTypeAhead extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final int minLines;
  final int? maxLines;
  final InputDecoration? decoration;

  const TextExpansionTypeAhead({
    super.key,
    required this.controller,
    this.labelText,
    this.minLines = 3,
    this.maxLines,
    this.decoration,
  });

  @override
  ConsumerState<TextExpansionTypeAhead> createState() => _TextExpansionTypeAheadState();
}

class _TextExpansionTypeAheadState extends ConsumerState<TextExpansionTypeAhead> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  
  OverlayEntry? _overlayEntry;
  List<TextExpansion> _suggestions = [];
  int _selectedIndex = 0;
  int _currentWordStart = 0;
  int _currentWordEnd = 0;
  bool _suppressSuggestions = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.controller.text;
    
    // Listen to changes from the original controller
    widget.controller.addListener(() {
      if (_textController.text != widget.controller.text) {
        _textController.text = widget.controller.text;
      }
    });

    // Listen to changes from our internal controller
    _textController.addListener(() {
      if (widget.controller.text != _textController.text) {
        widget.controller.text = _textController.text;
      }
      
      // If the selection has changed, update suggestions
      if (_textController.selection.isValid) {
        _updateSuggestions();
      }
    });

    // Add focus listener to show/hide overlay
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hideOverlay();
      } else {
        _updateSuggestions();
      }
    });
    
    // Add keyboard listener to handle navigation
    ServicesBinding.instance.keyboard.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.dispose();
    _textController.dispose();
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyPress);
    super.dispose();
  }

  void _updateSuggestions() {
    final textExpansions = ref.read(textExpansionsProvider).valueOrNull ?? [];
    if (textExpansions.isEmpty) return;

    final text = _textController.text;
    final cursorPosition = _textController.selection.baseOffset;
    if (cursorPosition < 0) return;

    // Get word at cursor
    final wordInfo = _getWordAtCursor(text, cursorPosition);
    if (wordInfo == null) {
      _hideOverlay();
      return;
    }

    final word = wordInfo.word;
    if (word.isEmpty || _suppressSuggestions) {
      _hideOverlay();
      return;
    }

    _currentWordStart = wordInfo.start;
    _currentWordEnd = wordInfo.end;

    // Find suggestions
    final exactMatches = textExpansions
        .where((item) => item.abbreviation.toLowerCase() == word.toLowerCase())
        .toList();

    final partialMatches = textExpansions
        .where((item) => 
            item.abbreviation.toLowerCase().contains(word.toLowerCase()) &&
            !exactMatches.contains(item))
        .toList();

    _suggestions = [...exactMatches, ...partialMatches];
    
    if (_suggestions.isNotEmpty) {
      _selectedIndex = 0;
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    
    _hideOverlay();

    // Position the tooltip higher above the text field
    final tooltipTop = offset.dy - 100; // Move it higher (100px instead of 50px)
    
    // Calculate a dynamic height based on suggestion count, but keep it small
    final suggestionsCount = min(_suggestions.length, 3);
    final dynamicHeight = 30.0 + (suggestionsCount * 24.0); // Header (30px) + items (24px each)
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 10,
        // Position higher above the text field
        top: max(tooltipTop, 0), // Ensure it doesn't go off screen
        width: size.width * 0.6, // Make it narrower
        child: Material(
          elevation: 4.0,
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: min(dynamicHeight, 80), // More strict height limit based on suggestion count
              maxWidth: size.width * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Simpler header with just the suggestion count
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.suggestionsCount(_suggestions.length),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Simplified list of suggestions - even more compact
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: min(_suggestions.length, 3), // Limit to 3 suggestions maximum
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return InkWell(
                        onTap: () => _applySuggestion(suggestion),
                        child: Container(
                          decoration: BoxDecoration(
                            color: index == _selectedIndex ? 
                                Colors.grey[100] : Colors.transparent,
                            border: index == _selectedIndex ? 
                                Border(left: BorderSide(color: Colors.blue[400]!, width: 3)) : null,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // More compact padding
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      suggestion.abbreviation,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      suggestion.expandedText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Simple checkmark for selected item
                              if (index == _selectedIndex) 
                                Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.blue[400],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _applySuggestion(TextExpansion suggestion) {
    final text = _textController.text;
    final beforeWord = text.substring(0, _currentWordStart);
    final afterWord = text.substring(_currentWordEnd);
    final newText = "$beforeWord${suggestion.expandedText}$afterWord";
    
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: beforeWord.length + suggestion.expandedText.length,
      ),
    );
    
    _hideOverlay();
    _suppressSuggestions = false;
  }

  @override
  Widget build(BuildContext context) {
    final textExpansionsAsync = ref.watch(textExpansionsProvider);
    
    return textExpansionsAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => _buildFallbackTextField(context),
      data: (textExpansions) => _buildTextField(context),
    );
  }

  Widget _buildFallbackTextField(BuildContext context) {
    return TextField(
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: TextInputType.multiline,
      decoration: widget.decoration ?? InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        constraints: const BoxConstraints(
          minHeight: double.infinity,
          minWidth: double.infinity,
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: TextInputType.multiline,
      decoration: widget.decoration ?? InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        constraints: const BoxConstraints(
          minHeight: double.infinity,
          minWidth: double.infinity,
        ),
      ),
      onChanged: (value) {
        // Additional handling for space auto-expansion
        if (value.endsWith(' ')) {
          final text = value.substring(0, value.length - 1);
          final wordInfo = _getLastWordInfo(text);
          if (wordInfo != null) {
            final word = wordInfo.word;
            final textExpansions = ref.read(textExpansionsProvider).valueOrNull ?? [];
            
            final exactMatch = textExpansions.firstWhere(
              (item) => item.abbreviation.toLowerCase() == word.toLowerCase(),
              orElse: () => TextExpansion(id: -1, abbreviation: '', expandedText: ''),
            );
            
            if (exactMatch.id != -1) {
              // Replace with expanded text
              final beforeWord = text.substring(0, wordInfo.start);
              final newText = "$beforeWord${exactMatch.expandedText} ";
              
              _textController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
          }
        }

        // Update suggestions based on current cursor position
        _updateSuggestions();
      },
      onTap: _updateSuggestions,
    );
  }

  // Get word at cursor position
  WordInfo? _getWordAtCursor(String text, int cursorPos) {
    // Find the start of the current word
    int startPos = cursorPos - 1;
    while (startPos >= 0 && !text[startPos].contains(RegExp(r'\s'))) {
      startPos--;
    }
    startPos++;

    // Find the end of the current word
    int endPos = cursorPos;
    while (endPos < text.length && !text[endPos].contains(RegExp(r'\s'))) {
      endPos++;
    }

    if (startPos < endPos) {
      return WordInfo(
        word: text.substring(startPos, endPos),
        start: startPos,
        end: endPos,
      );
    }
    return null;
  }

  // Get the last word in text
  WordInfo? _getLastWordInfo(String text) {
    if (text.isEmpty) return null;
    
    // Find the last space
    int lastSpaceIndex = text.lastIndexOf(' ');
    
    if (lastSpaceIndex == -1) {
      // No spaces, entire text is one word
      return WordInfo(word: text, start: 0, end: text.length);
    } else {
      // Get text after last space
      String lastWord = text.substring(lastSpaceIndex + 1);
      if (lastWord.isEmpty) return null;
      
      return WordInfo(
        word: lastWord,
        start: lastSpaceIndex + 1,
        end: text.length,
      );
    }
  }
  // Handle keyboard navigation for dropdown
  bool _handleKeyPress(KeyEvent event) {
    // Only handle keys when we have focus and suggestions are visible
    if (!_focusNode.hasFocus || _overlayEntry == null || _suggestions.isEmpty) {
      return false;
    }
    
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _suggestions.length;
          _showOverlay(); // Refresh overlay to update selection
        });
        return true;
      }
      
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + _suggestions.length) % _suggestions.length;
          _showOverlay(); // Refresh overlay to update selection
        });
        return true;
      }
      
      if (event.logicalKey == LogicalKeyboardKey.tab || 
          event.logicalKey == LogicalKeyboardKey.enter) {
        _applySuggestion(_suggestions[_selectedIndex]);
        return true;
      }
      
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _hideOverlay();
        _suppressSuggestions = true;
        return true;
      }
    }
    
    return false;
  }
} 