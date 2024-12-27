import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return HoverableIcon(
                icon: e,
                color: Colors.primaries[e.hashCode % Colors.primaries.length],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  T? _draggingItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return DragTarget<T>(
            onWillAcceptWithDetails: (details) {
              final draggedItem = details.data;
              return _items.contains(draggedItem);
            },
            onAcceptWithDetails: (details) {
              final draggedItem = details.data;
              setState(() {
                final fromIndex = _items.indexOf(draggedItem);
                if (fromIndex != -1) {
                  _items.removeAt(fromIndex);
                  _items.insert(index, draggedItem);
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: widget.builder(item),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: widget.builder(item),
                ),
                onDragStarted: () {
                  setState(() {
                    _draggingItem = item;
                  });
                },
                onDragEnd: (_) {
                  setState(() {
                    _draggingItem = null;
                  });
                },
                child: widget.builder(item),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}


class HoverableIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const HoverableIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  _HoverableIconState createState() => _HoverableIconState();
}

class _HoverableIconState extends State<HoverableIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.35 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48),
          height: 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.color,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
