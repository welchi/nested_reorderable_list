nested_reorderable_list
A Flutter package that provides a widget to create a nested reorderable list.

## Getting Started
This package provides a stateless widget, NestedReorderableList, which allows you to create a list with drag-and-drop item reordering functionality. This widget supports nested lists, meaning that list items can have their own children, which can also be reordered.

## Usage
First, you'll need to add nested_reorderable_list to your pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter

  nested_reorderable_list: ^0.1.0
```

Then, import the package in your Dart file:
```dart
import 'package:nested_reorderable_list/nested_reorderable_list.dart';
```

Here's a basic example of how to use the NestedReorderableList widget:
```dart
NestedReorderableList<String>(
  dragAndDropItems: items,
  itemBuilder: (BuildContext context, DragAndDropItem<String> item) => Text(item.content),
  onReorder: (SourceLocation source, DestinationLocation destination, DragAndDropItem<String> movedItem) {
    setState(() {
      // Determine the source and destination lists based on whether the parentIndex is null
      final sourceList = (source.parentIndex == null)
        ? items
        : items[source.parentIndex!].children;
      final destList = (destination.parentIndex == null)
        ? items
        : items[destination.parentIndex!].children;
        
      // Perform the removal and insertion operation
      final moved = sourceList.removeAt(source.index);
      final destinationIndex = destination.index;
      destList.insert(destinationIndex, moved);
    });
  },
);
```

In the example above, items is a list of DragAndDropItem instances, each of which contains a key for identification, the content of the item, and a list of child DragAndDropItem instances (if any). The itemBuilder is a function that takes a BuildContext and a DragAndDropItem and returns a Widget that represents the item. The onReorder function is called when a drag-and-drop operation finishes; it receives a SourceLocation and a DestinationLocation, which represent the initial and final locations of the dragged item, respectively.

## License
This project is licensed under the MIT License - see the LICENSE file for details.