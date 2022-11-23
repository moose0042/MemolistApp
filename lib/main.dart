import 'package:flutter/material.dart';
import 'memomodel.dart';

void main() {
  runApp(const memoapp());
}

class memoapp extends StatelessWidget {
  const memoapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MemolistPage(),
    );
  }
}

class MemolistPage extends StatefulWidget {
  const MemolistPage({Key? key}) : super(key: key);

  @override
  _MemolistPageState createState() => _MemolistPageState();
}

class _MemolistPageState extends State<MemolistPage> {
  List<Map<String, dynamic>> _memo = [];

  bool load = true;

  void _refreshJournals() async {
    final data = await memomodel.getmemos();
    setState(() {
      _memo = data;
      load = false;
    });
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    _titleController.text = "";
    _detailController.text = "";
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _memo.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _detailController.text = existingJournal['detail'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _detailController,
                    decoration: const InputDecoration(hintText: 'detail'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addmemo();
                        _titleController.text = "";
                        _detailController.text = "";
                        Navigator.of(context).pop();
                      }
                      if (id == null) {
                        await _updatememo(id!);
                        _titleController.text = "";
                        _detailController.text = "";
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(id == null ? '追加' : '更新'),
                  )
                ],
              ),
            ));
  }

  Future<void> _addmemo() async {
    await memomodel.createItem(_titleController.text, _detailController.text);
    _refreshJournals();
  }

  Future<void> _updatememo(int id) async {
    await memomodel.updatememo(
        id, _titleController.text, _detailController.text);
  }

  void _deletememo(int id) async {
    await memomodel.deletememo(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('ジャーナルの削除に成功！')));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('メモ'),
        ),
        body: ListView.builder(
          itemCount: _memo.length,
          itemBuilder: (context, index) => Card(
            color: Colors.green[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_memo[index]['title']),
              subtitle: Text(_memo[index]['detail']),
              trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showForm(_memo[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletememo(_memo[index]['id']),
                      ),
                    ],
                  )),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        ));
  }
}
/*
class MemoinputPage extends StatefulWidget {
  const MemoinputPage({Key? key}) : super(key: key);

  @override
  _MemoinputPageState createState() => _MemoinputPageState();
}

class _MemoinputPageState extends State<MemoinputPage> {

}

 */