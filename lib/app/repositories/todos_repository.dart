import 'package:todo_list/app/database/connection.dart';
import 'package:todo_list/app/models/todo_model.dart';

class TodosRepository {
  Future<List<TodoModel>> findByPeriod(DateTime start, DateTime end) async {
    var startFilter = DateTime(start.year, start.month, start.day, 0, 0, 0);
    var endFilter = DateTime(end.year, end.month, end.day, 23, 59, 59);

    var conn = await Connection().instance;

    var result = await conn.rawQuery(
      'select * from todo where data_hora between ? and ? order by data_hora',
      [startFilter.toIso8601String(), endFilter.toIso8601String()],
    );

    var tarefas = result.map((t) => TodoModel.fromMap(t)).toList();

    return tarefas;
  }

  Future<void> saveTodo(DateTime dataHoraTask, String descricao) async {
    var conn = await Connection().instance;
    await conn.rawInsert(
      'insert into todo(descricao,data_hora,finalizado) values(?,?,?)',
      [descricao, dataHoraTask.toIso8601String(), 0],
    );
  }

  Future<void> checkOrUncheckTodo(TodoModel todo) async {
    var conn = await Connection().instance;
    await conn.rawUpdate(
      'update todo set finalizado = ? where id = ?',
      [todo.finalizado ? 1 : 0, todo.id],
    );
  }

  Future<void> deleteTask(int id) async {
    var conn = await Connection().instance;
    await conn.rawDelete('delete from todo where id = ?', [id]);
  }
}
