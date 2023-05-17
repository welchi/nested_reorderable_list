import 'package:flutter/material.dart';
import 'package:nested_reorderable_list/nested_reorderable_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nested Reorderable List Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Nested Reorderable List Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DragAndDropItem<String>> items = [
    DragAndDropItem<String>(
      key: 'Item 1',
      content: 'Item 1',
      children: [
        DragAndDropItem<String>(
          key: 'Item 1.1',
          content: 'Item 1.1',
        ),
        DragAndDropItem<String>(
          key: 'Item 1.2',
          content: 'Item 1.2',
        ),
      ],
    ),
    DragAndDropItem<String>(
      key: 'Item 2',
      content: 'Item 2',
      children: [
        DragAndDropItem<String>(
          key: 'Item 2.1',
          content: 'Item 2.1',
        ),
        DragAndDropItem<String>(
          key: 'Item 2.2',
          content: 'Item 2.2',
        ),
      ],
    ),
    DragAndDropItem<String>(
      key: 'Item 3',
      content: 'Item 3',
      children: [
        DragAndDropItem<String>(
          key: 'Item 3.1',
          content: 'Item 3.1',
        ),
        DragAndDropItem<String>(
          key: 'Item 3.2',
          content: 'Item 3.2',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: NestedReorderableList(
          dragAndDropItems: items,
          itemBuilder: (context, item) => ListTile(
            key: Key(item.key),
            title: Text(item.content),
          ),
          onReorder: (source, destination, _) {
            setState(() {
              // Determine source and destination lists
              final sourceList = (source.parentIndex == null)
                  ? items
                  : items[source.parentIndex!].children;
              final destList = (destination.parentIndex == null)
                  ? items
                  : items[destination.parentIndex!].children;

              // Perform removal and insertion
              final moved = sourceList.removeAt(source.index);
              final destinationIndex = destination.index;
              destList.insert(destinationIndex, moved);
            });
          },
        ),
      ),
    );
  }
}
