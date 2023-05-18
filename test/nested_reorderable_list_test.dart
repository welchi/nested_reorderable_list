import 'package:flutter_test/flutter_test.dart';
import 'package:nested_reorderable_list/nested_reorderable_list.dart';

void main() {
  group('getDestinationLocation', () {
    test('returns correct location for asChild insert position', () {
      final parent = DragAndDropItem(key: 'parent', content: 'Parent');
      final items = [parent];

      final result = getDestinationLocation(
        index: 0,
        parent: parent,
        draggedCategoryIndex: 0,
        draggedCategoryParent: null,
        insertPosition: InsertPosition.asChild,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, 0);
      expect(result.index, 0); // always 0 for asChild
      expect(result.insertPosition, InsertPosition.asChild);
    });

    test('returns correct location for same parents and InsertPosition.before',
        () {
      final parent = DragAndDropItem(key: 'parent', content: 'Parent');
      final items = [parent];

      final result = getDestinationLocation(
        index: 5,
        parent: parent,
        draggedCategoryIndex: 3,
        draggedCategoryParent: parent,
        insertPosition: InsertPosition.before,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, 0); // index of parent in items
      expect(result.index, 4); // index - 1
      expect(result.insertPosition, InsertPosition.before);
    });

    test('returns correct location for same parents and InsertPosition.after',
        () {
      final parent = DragAndDropItem(key: 'parent', content: 'Parent');
      final items = [parent];

      final result = getDestinationLocation(
        index: 5,
        parent: parent,
        draggedCategoryIndex: 3,
        draggedCategoryParent: parent,
        insertPosition: InsertPosition.after,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, 0); // index of parent in items
      expect(result.index, 5); // index unchanged
      expect(result.insertPosition, InsertPosition.after);
    });

    test(
        'returns correct location for different parents and InsertPosition.after',
        () {
      final parent1 = DragAndDropItem(key: 'parent1', content: 'Parent 1');
      final parent2 = DragAndDropItem(key: 'parent2', content: 'Parent 2');
      final items = [parent1, parent2];

      final result = getDestinationLocation(
        index: 5,
        parent: parent1,
        draggedCategoryIndex: 3,
        draggedCategoryParent: parent2,
        insertPosition: InsertPosition.after,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, 0); // index of parent1 in items
      expect(result.index, 6); // index + 1
      expect(result.insertPosition, InsertPosition.after);
    });

    test(
        'returns correct location for different parents and InsertPosition.before',
        () {
      final parent1 = DragAndDropItem(key: 'parent1', content: 'Parent 1');
      final parent2 = DragAndDropItem(key: 'parent2', content: 'Parent 2');
      final items = [parent1, parent2];

      final result = getDestinationLocation(
        index: 5,
        parent: parent1,
        draggedCategoryIndex: 3,
        draggedCategoryParent: parent2,
        insertPosition: InsertPosition.before,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, 0); // index of parent1 in items
      expect(result.index, 5); // index unchanged
      expect(result.insertPosition, InsertPosition.before);
    });

    test('returns null parentIndex for top level items', () {
      final item1 = DragAndDropItem(key: 'item1', content: 'Item 1');
      final item2 = DragAndDropItem(key: 'item2', content: 'Item 2');
      final items = [item1, item2];

      final result = getDestinationLocation(
        index: 1,
        parent: null,
        draggedCategoryIndex: 0,
        draggedCategoryParent: null,
        insertPosition: InsertPosition.after,
        dragAndDropItems: items,
      );

      expect(result.parentIndex, isNull);
      expect(result.index, 1);
      expect(result.insertPosition, InsertPosition.after);
    });
  });
}
