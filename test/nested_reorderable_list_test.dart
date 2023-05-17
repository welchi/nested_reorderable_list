import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested_reorderable_list/nested_reorderable_list.dart';

void main() {
  testWidgets('', (tester) async {
    // Create a list of items
    final items = [
      DragAndDropItem<String>(
        key: 'Item 1',
        content: 'Item 1',
      ),
      DragAndDropItem<String>(
        key: 'Item 2',
        content: 'Item 2',
      ),
    ];

    // Create the widget
    final widget = MaterialApp(
      home: Scaffold(
        body: NestedReorderableList(
          dragAndDropItems: items,
          itemBuilder: (context, item) => Text(
            item.content,
          ),
          onReorder: (source, destination, movedItem) {
            // Implement reordering logic
          },
        ),
      ),
    );

    // Render the widget
    await tester.pumpWidget(widget);

    // Verify that the list is rendered
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Simulate a drag and drop operation
    await tester.drag(find.text('Item 1'), const Offset(0, 100));
    await tester.pumpAndSettle();
  });
}
