import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/modules/home/home_controller.dart';
import 'package:todo_list/app/modules/new_task/new_task_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              controller.title,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: FFNavigationBar(
            selectedIndex: controller.selectedTab,
            theme: FFNavigationBarTheme(
                itemWidth: 60,
                barHeight: 70,
                barBackgroundColor: Theme.of(context).primaryColor,
                unselectedItemIconColor: Colors.white,
                unselectedItemLabelColor: Colors.white,
                selectedItemBorderColor: Colors.white,
                selectedItemIconColor: Colors.white,
                selectedItemBackgroundColor: Theme.of(context).primaryColor,
                selectedItemLabelColor: Colors.black),
            items: [
              FFNavigationBarItem(
                iconData: Icons.check_circle,
                label: 'Finalizados',
              ),
              FFNavigationBarItem(
                iconData: Icons.view_week,
                label: 'Semanal',
              ),
              FFNavigationBarItem(
                iconData: Icons.calendar_today,
                label: 'Selecionar Data',
              ),
            ],
            onSelectTab: (index) => controller.changeSelectedTab(context, index),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: controller.listTodos?.keys?.length ?? 0,
              itemBuilder: (_, index) {
                var dayKey = controller.buscaDayKey(index);
                var todos = controller.listTodos[dayKey[0]];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dayKey[1],
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: controller.selectedTab != 0,
                            child: IconButton(
                              onPressed: () async {
                                await Navigator.of(context).pushNamed(NewTaskPage.routerName, arguments: dayKey[0]);
                                controller.update();
                              },
                              icon: Icon(
                                Icons.add_circle,
                                color: Theme.of(context).primaryColor,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        var todo = todos[index];
                        return ListTile(
                          leading: Checkbox(
                            activeColor: Theme.of(context).primaryColor,
                            value: todo.finalizado,
                            onChanged: (value) => controller.checkedOrUnchecked(todo),
                          ),
                          title: Text(
                            todo.descricao,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              decoration: todo.finalizado ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: Container(
                            width: 100,
                            height: 40,
                            //color: Colors.green,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '${todo.dataHora.hour.toString().padLeft(2, '0')}:${todo.dataHora.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    decoration: todo.finalizado ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => controller.delete(context, todo.id),
                                  child: Icon(
                                    Icons.delete,
                                    size: 25,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
