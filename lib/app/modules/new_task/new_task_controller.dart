import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/app/repositories/todos_repository.dart';

class NewTaskController extends ChangeNotifier {
  final dateFormat = DateFormat('dd/MM/yyyy');
  final formKey = GlobalKey<FormState>();
  final TodosRepository repository;

  TextEditingController nomeTaskController = TextEditingController();

  DateTime daySelected;
  String _validationNameError = '';
  String taskError;
  bool saved = false;
  bool loading = false;

  String get dayFormated => dateFormat.format(daySelected);

  String get validationNameError => _validationNameError;

  NewTaskController({@required this.repository, String day}) {
    daySelected = dateFormat.parse(day);
  }

  Future<void> save() async {
    validaTask(nomeTaskController.text);
    if (_validationNameError.isEmpty) {
      try {
        loading = true;
        saved = false;
        await repository.saveTodo(daySelected, nomeTaskController.text);
        saved = true;
        loading = false;
      } on Exception catch (e) {
        print(e);
        taskError = 'Erro ao salvar tarefa';
      }
    }
    notifyListeners();
  }

  void validaTask(String task) {
    _validationNameError = '';
    if (task.isEmpty) {
      _validationNameError = 'Nome da tarefa é obrigatório';
    }
  }
}
