import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app/modules/new_task/new_task_controller.dart';
import 'package:todo_list/app/shared/time_component.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key key}) : super(key: key);

  static const String routerName = '/new';

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<NewTaskController>(context, listen: false).addListener(() {
        var controller = context.read<NewTaskController>();

        if (controller.taskError != null) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                controller.taskError,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (controller.saved) {
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                'Tarefa cadastrada com sucesso',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          );
          controller.removeListener(() {});
          Future.delayed(Duration(seconds: 2), () => Navigator.pop(context));
        }
      });
    });
  }

  @override
  void dispose() {
    //Provider.of<NewTaskController>(context, listen: false).removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewTaskController>(
      builder: (context, controller, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOVA TAREFA',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 26),
                    Text(
                      'Data',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      controller.dayFormated,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Nome da Tarefa',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      //shadowColor: Theme.of(context).primaryColor, //Colors.grey[600],
                      child: Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        width: MediaQuery.of(context).size.width * .9,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 1.4),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: -1,
                              blurRadius: 8,
                              color: Colors.grey[700], //Theme.of(context).primaryColor,
                              offset: Offset(2, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: controller.nomeTaskController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        controller.validationNameError,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Hora',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TimeComponent(
                      date: controller.daySelected,
                      onSelectedTime: (date) {
                        controller.daySelected = date;
                      },
                    ),
                    SizedBox(height: 60),
                    _buildButton(context, controller),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, NewTaskController controller) {
    return Center(
      child: InkWell(
        onTap: () => !controller.saved ? controller.save() : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.decelerate,
          width: controller.saved ? 80 : MediaQuery.of(context).size.width,
          height: controller.saved ? 80 : 40,
          decoration: BoxDecoration(
            borderRadius: controller.saved ? BorderRadius.circular(100) : BorderRadius.circular(0),
            boxShadow: [
              controller.saved ? BoxShadow(offset: Offset(3, 12), blurRadius: 12, color: Colors.grey[800]) : BoxShadow(offset: Offset(2, 5), blurRadius: 5, color: Colors.grey[800]),
            ],
            color: Theme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: !controller.saved ? 0 : 80,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInBack,
                  opacity: !controller.saved ? 0 : 1,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Visibility(
                visible: !controller.saved,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
