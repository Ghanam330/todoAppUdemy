import 'package:bmi/components/components.dart';
import 'package:bmi/components/constants.dart';
import 'package:bmi/cubit_bloc/cubit_todo.dart';
import 'package:bmi/cubit_bloc/states.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class HomeLayout extends StatelessWidget {


  var scaffoldKey = GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();


  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   createDatabase();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShow) {
                  if (_formKey.currentState.validate()) {
                   cubit.insertDatabase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text,);
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) => Container(
                          padding: EdgeInsets.all(20.0),
                          color: Colors.white,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  type: TextInputType.text,
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'title must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) => timeController.text =
                                        value.format(context).toString());
                                  },
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'Time must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Time',
                                  prefix: Icons.watch_later_outlined,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('20121-05-03'),
                                    ).then(
                                      (value) => dateController.text =
                                          DateFormat.yMMMd().format(value),
                                    );
                                  },
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'Date must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Data',
                                  prefix: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {

                        cubit.changeBottomSheetState(
                            isShow: false,
                            icon: Icons.edit);

                  });

                  cubit.changeBottomSheetState(
                      isShow:true,
                      icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'new Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archive'),
              ],
            ),
          );
        },
      ),
    );
  }


}
