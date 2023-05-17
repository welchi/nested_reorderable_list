import 'package:flutter/material.dart';

/// A type definition for a function that builds a `DragAndDropItem`.
///
/// It takes a [BuildContext] and a [DragAndDropItem] as input parameters
/// and returns a [Widget].
typedef DragAndDropItemBuilder<T> = Widget Function(
  BuildContext context,
  DragAndDropItem<T> item,
);

/// A type definition for a function that's called
/// when a drag operation finishes.
///
/// It takes a [SourceLocation], a [DestinationLocation],
/// and a [DragAndDropItem] as parameters.
typedef OnDragFinish<T> = void Function(
  SourceLocation source,
  DestinationLocation destination,
  DragAndDropItem<T> movedItem,
);

/// Class representing an item in the drag and drop operation.
///
/// It contains a [key] for identifying the item and the [content] of the item.
/// It can also have a list of children [DragAndDropItem]s.
class DragAndDropItem<T> {
  DragAndDropItem({
    required this.key,
    required this.content,
    List<DragAndDropItem<T>>? children,
  }) : children =
            children != null ? List<DragAndDropItem<T>>.from(children) : [];

  /// The content of the item.
  final T content;

  /// The key that identifies the item.
  final String key;

  /// The children of this item.
  List<DragAndDropItem<T>> children;
}

/// Class representing the source location of a drag and drop operation.
///
/// It contains the [parentIndex] and the [index] of the item
/// in the source location.
class SourceLocation {
  SourceLocation({
    required this.parentIndex,
    required this.index,
  });

  /// The index of the parent of the item.
  final int? parentIndex;

  /// The index of the item.
  final int index;
}

/// Class representing the destination location of a drag and drop operation.
///
/// Similar to [SourceLocation], it contains the [parentIndex]
/// and the [index] of the item.
/// It also contains an [insertPosition]
/// which represents the position where the item should be inserted
/// in the destination location.
class DestinationLocation {
  DestinationLocation({
    required this.parentIndex,
    required this.index,
    required this.insertPosition,
  });

  /// The index of the parent of the drop location.
  final int? parentIndex;

  /// The index of the drop location.
  final int index;

  /// The position where the item is inserted relative to the drop location.
  final InsertPosition insertPosition;
}

/// Enum representing the insert position of a drag and drop item
/// in the destination location.
enum InsertPosition {
  /// Insert the item before the drop location.
  before,

  /// Insert the item after the drop location.
  after,

  /// Insert the item as a child of the drop location.
  asChild,
}

const _spaceSize = 32.0;

/// A Stateless widget that represents a nested reorderable list.
///
/// It takes a list of [DragAndDropItem]s, a [DragAndDropItemBuilder]
/// for building each item,
/// and an [OnDragFinish] callback that's called when a drag operation finishes.
class NestedReorderableList<T> extends StatelessWidget {
  const NestedReorderableList({
    super.key,
    required this.dragAndDropItems,
    required this.itemBuilder,
    required this.onReorder,
    this.showDragTargetOnlyDuringDrag = false,
    this.dropTargetSize = 8.0,
    this.debugShowDragTarget = false,
  });

  /// The items of the list.
  final List<DragAndDropItem<T>> dragAndDropItems;

  /// The builder function for generating widgets for items.
  final DragAndDropItemBuilder<T> itemBuilder;

  /// The callback that's called when a drag operation is completed.
  final OnDragFinish<T> onReorder;

  /// Whether to show drag targets only during drag.
  final bool showDragTargetOnlyDuringDrag;

  /// The size of the drop target.
  final double dropTargetSize;

  /// Whether to enable debug mode.
  final bool debugShowDragTarget;

  @override
  Widget build(BuildContext context) {
    return _NestedReorderableList<T>(
      dragAndDropItems: dragAndDropItems,
      itemBuilder: itemBuilder,
      onReorder: onReorder,
      showDragTargetOnlyDuringDrag: showDragTargetOnlyDuringDrag,
      dropTargetSize: dropTargetSize,
      debugShowDragTarget: debugShowDragTarget,
    );
  }
}

/// A private StatefulWidget that represents the nested reorderable list.
///
/// It's similar to [NestedReorderableList], but it's stateful
/// because it needs to manage the state of the drag and drop operation.
class _NestedReorderableList<T> extends StatefulWidget {
  const _NestedReorderableList({
    super.key,
    required this.dragAndDropItems,
    required this.itemBuilder,
    required this.onReorder,
    required this.showDragTargetOnlyDuringDrag,
    required this.dropTargetSize,
    required this.debugShowDragTarget,
  });
  final List<DragAndDropItem<T>> dragAndDropItems;
  final DragAndDropItemBuilder<T> itemBuilder;
  final OnDragFinish<T> onReorder;
  final bool showDragTargetOnlyDuringDrag;
  final double dropTargetSize;
  final bool debugShowDragTarget;

  @override
  _NestedReorderableListState<T> createState() => _NestedReorderableListState();
}

/// The State of [_NestedReorderableList].
///
/// It manages the state of the drag and drop operation
/// such as the item being dragged,
/// the target category of the item, and the position
/// where the item should be inserted.
class _NestedReorderableListState<T> extends State<_NestedReorderableList<T>> {
  bool _dragging = false;
  DragAndDropItem<T>? _draggingCategory;
  DragAndDropItem<T>? _dropTargetCategory;
  InsertPosition? _dropPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.dragAndDropItems.length; i++)
          _buildListItem(
            category: widget.dragAndDropItems[i],
            index: i,
            level: 0,
          ),
      ],
    );
  }

  Widget _buildListItem({
    required DragAndDropItem<T> category,
    required int index,
    required int level,
    DragAndDropItem<T>? parent,
  }) {
    final childrenVisibility = !_shouldHideChildren(
      category: category,
      level: level,
    );

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: level * _spaceSize,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLineDragTarget(
                    category: category,
                    index: index,
                    level: level,
                    parent: parent,
                    insertPosition: InsertPosition.before,
                    color: widget.debugShowDragTarget
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.transparent,
                    dragTargetSize: 0,
                  ),
                  if (_shouldShowDragTarget(
                    category: category,
                  ))
                    _buildDragTarget(
                      category: category,
                      index: index,
                      level: level,
                      parent: parent,
                    ),
                ],
              ),
            ),
          ],
        ),
        if (childrenVisibility)
          for (final child in category.children)
            _buildListItem(
              category: child,
              index: category.children.indexOf(
                child,
              ),
              level: level + 1,
              parent: category,
            ),
        if (_shouldShowEmptyChildDragTarget(
          category,
          level,
        ))
          _buildLineDragTarget(
            category: category,
            index: index,
            level: level,
            parent: parent,
            insertPosition: InsertPosition.asChild,
            color: widget.debugShowDragTarget
                ? Colors.yellow.withOpacity(0.2)
                : Colors.transparent,
            dragTargetSize: widget.dropTargetSize,
          ),
        if (_shouldShowBelowDragTarget(
          category: category,
          index: index,
          parent: parent,
        ))
          _buildLineDragTarget(
            category: category,
            index: index,
            level: level,
            parent: parent,
            insertPosition: InsertPosition.after,
            color: widget.debugShowDragTarget
                ? Colors.red.withOpacity(0.2)
                : Colors.transparent,
            dragTargetSize: widget.dropTargetSize,
          ),
      ],
    );
  }

  bool _shouldShowDragTarget({
    required DragAndDropItem<T> category,
  }) {
    return _draggingCategory?.key != category.key;
  }

  bool _shouldShowBelowDragTarget({
    required DragAndDropItem<T> category,
    required int index,
    required DragAndDropItem<T>? parent,
  }) {
    final isLastCategoryInLevel = parent == null
        ? index == widget.dragAndDropItems.length - 1
        : index == parent.children.length - 1;

    return isLastCategoryInLevel &&
        _draggingCategory?.key != category.key &&
        (!widget.showDragTargetOnlyDuringDrag ||
            (_dragging && widget.showDragTargetOnlyDuringDrag));
  }

  bool _shouldHideChildren({
    required DragAndDropItem<T> category,
    required int level,
  }) {
    return level == 0 &&
        _draggingCategory != null &&
        _draggingCategory!.key == category.key;
  }

  Widget _buildDragTarget({
    required DragAndDropItem<T> category,
    required int index,
    required int level,
    DragAndDropItem<T>? parent,
  }) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, _, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _buildDraggable(
                category: category,
                index: index,
                level: level,
                parent: parent,
              ),
            ),
          ],
        );
      },
      onWillAccept: (draggedData) {
        return _handleOnWillAccept(
          level,
        );
      },
      onAccept: (draggedData) {
        // For some reason, even if onWillAccept() is false,
        // onAccept() can sometimes be called, so we check here as well.
        if (!_handleOnWillAccept(
          level,
        )) {
          return;
        }
        _handleDragAccept(
          draggedData: draggedData,
          parent: parent,
          index: index,
          insertPosition: InsertPosition.before,
        );
      },
      onMove: (moveData) {
        setState(() {
          _dropTargetCategory = category;
          _dropPosition = InsertPosition.before;
        });
      },
      onLeave: (leaveData) {
        setState(() {
          _dropTargetCategory = null;
          _dropPosition = null;
        });
      },
    );
  }

  Widget _buildLineDragTarget({
    required DragAndDropItem<T> category,
    required int index,
    required int level,
    DragAndDropItem<T>? parent,
    required InsertPosition insertPosition,
    required Color color,
    required double dragTargetSize,
  }) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, _, __) {
        return Row(
          children: [
            SizedBox(
              width: ((insertPosition == InsertPosition.before && level > 0
                          ? 0
                          : level) +
                      (insertPosition == InsertPosition.asChild ? 1 : 0)) *
                  _spaceSize,
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: dragTargetSize,
                    color: color,
                    child: widget.debugShowDragTarget
                        ? Text(
                            'index: $index, insertPosition: $insertPosition',
                            style: const TextStyle(
                              fontSize: 8,
                            ),
                          )
                        : null,
                  ),
                  if (_dropTargetCategory?.key == category.key &&
                      _dropPosition == insertPosition &&
                      _handleOnWillAccept(
                        level,
                      ))
                    Opacity(
                      opacity: 0.2,
                      child: widget.itemBuilder(
                        context,
                        _draggingCategory!,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
      onWillAccept: (draggedData) {
        return _handleOnWillAccept(
          level,
        );
      },
      onAccept: (draggedData) {
        // For some reason, even if onWillAccept() is false,
        // onAccept() can sometimes be called, so we check here as well.
        if (!_handleOnWillAccept(
          level,
        )) {
          return;
        }
        _handleDragAccept(
          draggedData: draggedData,
          parent: parent,
          index: index,
          insertPosition: insertPosition,
        );
      },
      onMove: (moveData) {
        setState(() {
          _dropTargetCategory = category;
          _dropPosition = insertPosition;
        });
      },
      onLeave: (leaveData) {
        // When attempting to drag & drop outside of the allowable range,
        // we make the Ghost invisible.
        if (parent == null &&
            (index == 0 || index == widget.dragAndDropItems.length - 1)) {
          setState(() {
            _dropTargetCategory = null;
            _dropPosition = null;
          });
        }
      },
    );
  }

  Widget _buildDraggable({
    required DragAndDropItem<T> category,
    required int index,
    required int level,
    DragAndDropItem<T>? parent,
  }) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: {
        'category': category,
        'index': index,
        'level': level,
        'parent': parent,
      },
      feedback: Card(
        elevation: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - level * 30.0,
          ),
          child: Material(
            child: widget.itemBuilder(
              context,
              category,
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        setState(() {
          _dragging = true;
          _draggingCategory = category;
        });
      },
      onDragCompleted: () {
        setState(() {
          _dragging = false;
          _draggingCategory = null;
          _dropTargetCategory = null;
          _dropPosition = null;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _dragging = false;
          _draggingCategory = null;
          _dropTargetCategory = null;
          _dropPosition = null;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            child: widget.itemBuilder(
              context,
              category,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowEmptyChildDragTarget(
    DragAndDropItem<T> category,
    int level,
  ) {
    return level == 0 &&
        category.children.isEmpty &&
        category.key != _draggingCategory?.key &&
        (!widget.showDragTargetOnlyDuringDrag ||
            (!widget.showDragTargetOnlyDuringDrag ||
                (_dragging && widget.showDragTargetOnlyDuringDrag)));
  }

  bool _handleOnWillAccept(int level) {
    if (_dropPosition == InsertPosition.asChild) {
      return _draggingCategory?.children.isEmpty ?? true;
    }
    // At level 1, we do not accept items with child elements.
    if (level == 1) {
      return _draggingCategory?.children.isEmpty ?? true;
    }

    // At level 0, we always accept.
    return true;
  }

  void _handleDragAccept({
    required Map<String, dynamic> draggedData,
    required int index,
    DragAndDropItem<T>? parent,
    required InsertPosition insertPosition,
  }) {
    final draggedCategoryIndex = draggedData['index'] as int;
    final draggedCategoryParent = draggedData['parent'] as DragAndDropItem<T>?;
    final sourceParentIndex = draggedCategoryParent != null
        ? widget.dragAndDropItems.indexOf(
            draggedCategoryParent,
          )
        : null;
    final sourceLocation = SourceLocation(
      parentIndex: sourceParentIndex,
      index: draggedCategoryIndex,
    );

    final draggedCategory = sourceLocation.parentIndex != null
        ? widget.dragAndDropItems[sourceLocation.parentIndex!]
            .children[sourceLocation.index]
        : widget.dragAndDropItems[sourceLocation.index];

    // There's a special process for adding child elements to parent elements
    // that don't have child elements.
    if (insertPosition == InsertPosition.asChild) {
      final destinationLocation = DestinationLocation(
        parentIndex: index,
        index: 0,
        insertPosition: insertPosition,
      );

      widget.onReorder(
        sourceLocation,
        destinationLocation,
        draggedCategory,
      );

      return;
    }

    // When reordering between parent elements or between child elements
    // that have the same parent, and the drop point (index) is behind
    // the dragged point, and the InsertPosition is before,
    // we reduce the index by 1
    // (since one element has been pulled out by the drag).
    final indexDiff = draggedCategoryParent?.key == parent?.key &&
            index > draggedCategoryIndex &&
            insertPosition == InsertPosition.before
        ? 1
        : 0;

    final destinationParentIndex = parent != null
        ? widget.dragAndDropItems.indexOf(
            parent,
          )
        : null;
    final destinationLocation = DestinationLocation(
      parentIndex: destinationParentIndex,
      index: index - indexDiff,
      insertPosition: insertPosition,
    );

    widget.onReorder(
      sourceLocation,
      destinationLocation,
      draggedCategory,
    );
  }
}
