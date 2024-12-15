
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job_pulse/Widget/personList.dart';
import 'package:provider/provider.dart';


import '../Pages/company/Edit_job_Post.dart';
import '../main.dart';
import '../model/model.dart';
import '../model/service.dart';
import 'contactList.dart';
import 'snackbar.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  employee_job_post? jobPost;

  MyListTile({
    required this.title,
    required this.subTitle,
    this.jobPost
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MyListTileState>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/department.svg',
                            semanticsLabel: 'My SVG Image',
                            height: 20,
                            width: 20,
                          ),
                          /*Image.asset(
                            'assets/diamond.png',
                            heig  ht: 28,
                          ),*/
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${AppLocalizations.of(context)!.translate(jobPost!.departmentName!) ?? jobPost!.departmentName }",
                            style: TextStyle(color: Colors.black,
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        children: [
                          /*Image.asset(
                            'assets/diamond.png',
                            height: 28,
                          ),*/
                          SvgPicture.asset(
                            'assets/designation.svg',
                            semanticsLabel: 'My SVG Image',
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${AppLocalizations.of(context)!.translate(jobPost!.designationName!) ?? jobPost!.designationName }",
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Colors.black,
                                fontSize: 16, fontWeight: FontWeight.w500),

                          ),
                        ],
                      ),
                      SizedBox(width: 10,),

                    ],
                  ),
                  //second row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      jobPost!.requirementTypes == false ? Text("Expected Salary :- ₹${jobPost!.salary}") :Text("Expected Price per piece :- ₹${jobPost!.price}") ,
                      IconButton(

                        color: Colors.red, onPressed: () async{
                        _showDeleteConfirmationDialog(context);
                        //await Future.delayed(const Duration(seconds: 3));

                      }, icon: Icon(Icons.delete),
                      ),
                    ],
                  ),

                ],
              ),

              // trailing: Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     IconButton(
              //       icon: state.isPersonInfo
              //           ? Icon(Icons.info)
              //           : Icon(Icons.info_outline),
              //       onPressed: () {
              //         state.pressPersonInfo();
              //       },
              //     ),
              //     IconButton(
              //       icon: state.isContactInfo
              //           ? Icon(Icons.call)
              //           : Icon(Icons.call_end),
              //       onPressed: () {
              //         // Add your secondary action logic here
              //         state.pressContactInfo();
              //       },
              //     ),
              //   ],
              // ),
            ),
          ),
        ),

      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('Confirm Delete') ?? "Confirm Delete"),
          content: Text(AppLocalizations.of(context)!.translate('Are you sure you want to delete this post?') ??'Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Perform the delete operation here
                // Replace this with your actual delete logic

               // JobPostService().jobPostDelete(jobPost!.id.toString());

                EmployeViewJobPostService().jobPostDelete(jobPost!.sId!);
            //    snackBar().display(context, AppLocalizations.of(context)!.translate("Job Post Deleted Successfuly")??"Job Post Deleted Successfuly", Colors.red);

                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                primary: Colors.red, // Button text color
              ),
              child: Text(AppLocalizations.of(context)!.translate('Delete')??"Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                primary: Colors.blue, // Button text color
              ),
              child: Text(AppLocalizations.of(context)!.translate('Cancel')??"Cancel"),
            ),
          ],
        );
      },
    );
  }
}
