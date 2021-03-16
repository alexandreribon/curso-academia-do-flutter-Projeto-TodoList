import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/models/todo_model.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';
import 'package:collection/collection.dart';

class HomeController extends ChangeNotifier {
  final TodosRepository repository;
  final dateFormat = DateFormat('dd/MM/yyyy');

  int antSelectedTab;
  int selectedTab = 1;

  DateTime daySelected;
  DateTime startFilter;
  DateTime endFilter;
  Map<String, List<TodoModel>> listTodos;

  String _title;

  String get title => _title;

  HomeController({@required this.repository}) {
    findAllTaskForWeek();
  }

  Future<void> findAllTaskForWeek() async {
    _title = 'Atividades da semana';

    daySelected = DateTime.now();

    startFilter = DateTime.now();

    if (startFilter.weekday != DateTime.monday) {
      startFilter = startFilter.subtract(Duration(days: startFilter.weekday - 1));
    }
    endFilter = startFilter.add(Duration(days: 6));

    var todos = await repository.findByPeriod(startFilter, endFilter);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(DateTime.now()): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    notifyListeners();
  }

  void filterFinalized() {
    listTodos = listTodos.map((key, value) {
      var todosFinalized = value.where((t) => t.finalizado).toList();
      return MapEntry(key, todosFinalized);
    });
    listTodos.removeWhere((key, value) => value.isEmpty);
    notifyListeners();
  }

  void checkedOrUnchecked(TodoModel todo) {
    if (selectedTab != 0) {
      todo.finalizado = !todo.finalizado;
      notifyListeners();
      repository.checkOrUncheckTodo(todo);
    }
  }

  Future<void> findAllBySelectedDay() async {
    _title = 'Atividades do dia selecionado';

    var todos = await repository.findByPeriod(daySelected, daySelected);

    if (todos.isEmpty) {
      listTodos = {dateFormat.format(daySelected): []};
    } else {
      listTodos = groupBy(todos, (TodoModel todo) => dateFormat.format(todo.dataHora));
    }

    notifyListeners();
  }

  Future<void> changeSelectedTab(BuildContext context, int index) async {
    antSelectedTab = selectedTab;
    selectedTab = index;
    switch (index) {
      case 0:
        if (antSelectedTab == 1) {
          _title = 'Atividades finalizadas da semana';
        } else if (antSelectedTab == 2) {
          _title = 'Atividades finalizadas do dia ';
        }
        filterFinalized();
        break;
      case 1:
        findAllTaskForWeek();
        break;
      case 2:
        var day = await showDatePicker(
          context: context,
          initialDate: daySelected,
          firstDate: DateTime.now().subtract(Duration(days: (360 * 3))),
          lastDate: DateTime.now().add(Duration(days: (360 * 3))),
        );

        if (day != null) {
          daySelected = day;
          findAllBySelectedDay();
        } else {
          selectedTab = antSelectedTab;
        }

        break;
    }
    notifyListeners();
  }

  void update() {
    if (selectedTab == 1) {
      findAllTaskForWeek();
    } else if (selectedTab == 2) {
      findAllBySelectedDay();
    }
  }

  Future<void> delete(BuildContext context, int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Exclusão',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Deseja excluir essa tarefa?',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 18),
              ),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Excluir',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete != null) {
      if (confirmDelete) {
        await repository.deleteTask(id);

        if (selectedTab != 0) {
          update();
        } else {
          bool taskRemoved = false;
          for (var todos in listTodos.values) {
            for (var todo in todos) {
              if (todo.id == id) {
                todos.remove(todo);
                taskRemoved = true;
                break;
              }
            }
            if (taskRemoved) {
              break;
            }
          }
          listTodos.removeWhere((key, value) => value.isEmpty);
          notifyListeners();
        }
      }
    }
  }

  List<String> buscaDayKey(int index) {
    var key = listTodos.keys.elementAt(index);

    List<String> dayKey;

    var today = DateTime.now();
    if (key == dateFormat.format(today)) {
      dayKey = [key, 'HOJE'];
    } else if (key == dateFormat.format(today.add(Duration(days: 1)))) {
      dayKey = [key, 'AMANHÃ'];
    } else {
      dayKey = [key, key];
    }

    return dayKey;
  }
}
