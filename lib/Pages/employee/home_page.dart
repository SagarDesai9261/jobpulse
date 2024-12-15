import 'dart:convert';
import 'package:job_pulse/Pages/employee/create_job_post.dart';
import 'package:job_pulse/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frino_icons/frino_icons.dart';
import 'package:http/http.dart' as http;

import 'package:job_pulse/Pages/employee/notification_data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:job_pulse/Pages/employee/show_job_posts.dart';
import 'package:job_pulse/Widget/banner_slider.dart';
import 'package:job_pulse/model/model.dart';
import 'package:job_pulse/model/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Ad_Helper.dart';
import '../../Widget/EmployeeListTile.dart';
import '../Custom_Drawer.dart';

class Home_page_employee extends StatefulWidget {
  const Home_page_employee({Key? key}) : super(key: key);

  @override
  State<Home_page_employee> createState() => _Home_page_employeeState();
}

class _Home_page_employeeState extends State<Home_page_employee> {
  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  int selectedPos = 0;
  BannerAd? _bannerAd;
  String? _selecteddepartment;
  String? _selecteddesignation;
  List? department = [];
  List? designation = [];
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  double bottomNavBarHeight = 60;
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;

  List<TabItem> tabItems = List.of([
    TabItem(
      Icons.home,
      "Home".tr(),
      Colors.blue,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.supervised_user_circle,
      "All Post".tr(),
      Colors.orange,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.list_alt,
      "View Job Post".tr(),
      Colors.teal,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.add,
      "Create JobPost".tr(),
      Colors.green,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
  ]);

  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    fetch_department();
    fetch_designation();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print("error $err");
          ad.dispose();
        },
      ),
    ).load();
    _navigationController = CircularBottomNavigationController(selectedPos);
  }

  @override
  Widget build(BuildContext context) {
    List<TabItem> tabItems = List.of([
      TabItem(
        Icons.home,
        AppLocalizations.of(context)!.translate("Home") ?? "Home",
        Colors.blue,
        labelStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      TabItem(
        Icons.supervised_user_circle,
        AppLocalizations.of(context)!.translate("All Post") ?? "All Post",
        Colors.orange,
        labelStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      TabItem(
        Icons.list_alt,
        AppLocalizations.of(context)!.translate("View Job Post") ??
            "View Job Post",
        Colors.teal,
        labelStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      TabItem(
        Icons.add,
        AppLocalizations.of(context)!.translate("Create Post") ??
            "Create New Post",
        Colors.green,
        labelStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('Job Pulse') ??
              "Job Pulse"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()));
                },
                icon: const Icon(Icons.notifications_active_outlined))
          ],
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: bottomNavBarHeight),
              child: bodyContainer(),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircularBottomNavigation(
                      tabItems,
                      controller: _navigationController,
                      selectedPos: selectedPos,
                      barHeight: bottomNavBarHeight,
                      // use either barBackgroundColor or barBackgroundGradient to have a gradient on bar background
                      barBackgroundColor: Colors.white,
                      // barBackgroundGradient: LinearGradient(
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      //   colors: [
                      //     Colors.blue,
                      //     Colors.red,
                      //   ],
                      // ),
                      backgroundBoxShadow: const <BoxShadow>[
                        BoxShadow(color: Colors.black45, blurRadius: 10.0),
                      ],
                      animationDuration: const Duration(milliseconds: 300),
                      selectedCallback: (int? selectedPos) {
                        setState(() {
                          this.selectedPos = selectedPos ?? 0;
                          if (kDebugMode) {
                            print(_navigationController.value);
                          }
                        });
                      },
                    ),
                    if (_bannerAd != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    if (_bannerAd == null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * .8,
                          height: MediaQuery.of(context).size.height * .04,
                          decoration: BoxDecoration(border: Border.all()),
                          child: const Text("No Ads "),
                        ),
                      ),
                  ],
                )),
          ],
        ),
        drawer: const CustomDrawer(
          isEmployee: true,
        ),
        floatingActionButton: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }

  Widget bodyContainer() {
    switch (selectedPos) {
      case 0:
        return home_view();
      case 1:
        return const ShowAllCategories();
      case 2:
        return Employee_view_job_post();
      case 3:
        return Create_job_post();
    }
    return Container();
  }

  Future<void> fetch_department() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    final response = await http.get(Uri.parse(
        "https://admin.job-pulse.com/api/department/department/${data["industry"]}"));
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          department = data["data"];
          department!.insert(0, {"departmentName": "All"});
          _selecteddepartment = department![0]["departmentName"];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  fetch_designation() async {
    var endpointUrl =
        'https://admin.job-pulse.com/api/designation/$_selecteddepartment';
    var response = await http.get(Uri.parse(endpointUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        designation = data["data"];
        designation = data["data"];
        designation!.insert(0, {"designationName": "All"});
        _selecteddesignation = designation![0]["designationName"];
      });
    } else {
      setState(() {
        designation = [];
      });
      //  designation = [];
    }
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App').tr(),
            content: Text(AppLocalizations.of(context)!
                    .translate('Do you want to exit an App?') ??
                "Do you want to exit an App?'"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No').tr(),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home_page_employee()), (route) => false);
                  SystemNavigator.pop();
                },
                //return true when click on "Yes"
                child: const Text('Yes').tr(),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  Employee_view_job_post() {
    final jobPostService = EmployeViewJobPostService();
    //final diamondProvider = Provider.of<DiamondProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .3,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Department"),
                      value: _selecteddepartment,
                      onChanged: (newValue) {
                        setState(() {
                          _selecteddepartment = newValue!;
                          fetch_designation();
                          // fetch_designation();
                        });
                      },
                      items: department!.map((diamondTypeList) {
                        return DropdownMenuItem<String>(
                          value: diamondTypeList["departmentName"],
                          child: Text(AppLocalizations.of(context)!.translate(
                                  diamondTypeList["departmentName"]) ??
                              diamondTypeList["departmentName"]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .45,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Designation"),
                      value: _selecteddesignation,
                      onChanged: (newValue) {
                        setState(() {
                          _selecteddesignation = newValue!;
                          // fetch_designation();
                        });
                      },
                      items: designation!.map((workTypeList) {
                        return DropdownMenuItem<String>(
                          value: workTypeList["designationName"],
                          child: Text(AppLocalizations.of(context)!
                                  .translate(workTypeList["designationName"]) ??
                              workTypeList["designationName"]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: MediaQuery.of(context).size.height * .06,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      iconSize: 0.0,
                      value: selectedOption3,
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption3 = newValue!;
                        });
                      },
                      items:
                          options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: value == "Option 1"
                              ? Image.asset("assets/male.png")
                              : value == "Option 2"
                                  ? Image.asset("assets/female.png")
                                  : Image.asset("assets/both.png"),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BannerSlider(),
          StreamBuilder<List<employee_job_post>>(
            stream: jobPostService
                .fetchJobPosts(), // Make sure this returns a Stream<List<JobPost>>
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text('Error fetching data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text(AppLocalizations.of(context)!
                            .translate('No job posts available') ??
                        "No job posts available"));
              } else {
                // var filteredJobPosts;
                var filteredJobPosts;

                if (_selecteddepartment == "All" &&
                    selectedOption3 == "Option 1") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.gender == "Male";
                  }).toList();
                  // filteredJobPosts = snapshot.data;
                } else if (_selecteddepartment == "All" &&
                    selectedOption3 == "Option 2") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.gender == "Female";
                  }).toList();
                } else if (_selecteddesignation == "All" &&
                    selectedOption3 == "Option 1") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.departmentName == _selecteddepartment &&
                        jobPost.gender == "Male";
                  }).toList();
                } else if (_selecteddesignation == "All" &&
                    selectedOption3 == "Option 2") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.departmentName == _selecteddepartment &&
                        jobPost.gender == "Female";
                  }).toList();
                } else if (selectedOption3 == "Option 1") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.departmentName == _selecteddepartment &&
                        jobPost.designationName == _selecteddesignation &&
                        jobPost.gender == "Male";
                  }).toList();
                } else if (selectedOption3 == "Option 2") {
                  filteredJobPosts = snapshot.data!.where((jobPost) {
                    return jobPost.departmentName == _selecteddepartment &&
                        jobPost.designationName == _selecteddesignation &&
                        jobPost.gender == "Female";
                  }).toList();
                }

                // Your filtering logic here...

                if (filteredJobPosts.length == 0) {
                  return const Center(
                    child: Text("No Record Found"),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height < 650
                      ? MediaQuery.of(context).size.height * .4
                      : MediaQuery.of(context).size.height * .5,
                  child: ListView.builder(
                    itemCount: filteredJobPosts.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider(
                        create: (context) => MyListTileState(),
                        child: MyListTile(
                          title: 'List Tile $index',
                          subTitle: 'Subtitle for Tile $index',
                          jobPost: filteredJobPosts[index],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  home_view() {
    return WillPopScope(onWillPop: showExitPopup, child: const Job_post());
  }

  Widget bottomNav() {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      selectedPos: selectedPos,
      barHeight: bottomNavBarHeight,
      // use either barBackgroundColor or barBackgroundGradient to have a gradient on bar background
      barBackgroundColor: Colors.white,
      // barBackgroundGradient: LinearGradient(
      //   begin: Alignment.bottomCenter,
      //   end: Alignment.topCenter,
      //   colors: [
      //     Colors.blue,
      //     Colors.red,
      //   ],
      // ),
      backgroundBoxShadow: const <BoxShadow>[
        BoxShadow(color: Colors.black45, blurRadius: 10.0),
      ],
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (int? selectedPos) {
        setState(() {
          this.selectedPos = selectedPos ?? 0;
          if (kDebugMode) {
            print(_navigationController.value);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}

class Job_post extends StatefulWidget {
  const Job_post({Key? key}) : super(key: key);

  @override
  State<Job_post> createState() => _Job_postState();
}

class _Job_postState extends State<Job_post> {
  late SharedPreferences sharedPrefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => sharedPrefs = prefs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerProvider =
        Provider.of<BannerDataProvider>(context, listen: false);
    bannerProvider.fetchBanners();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BannerSlider(),
            StreamBuilder<List<JobPost>>(
                stream: employee_job_post_details().fetchJobPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {}
                  return display_post(snapshot.data!);
                }),
          ],
        ),
      ),
    );
  }

  Widget display_post(List<JobPost> snapshotdata) {
    Map<String, dynamic> data =
        json.decode(sharedPrefs.getString("user_details")!);

    var filterdata = snapshotdata
        .where((element) => element.designationName == data["designation"])
        .toList();
    if (filterdata.length == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!
                  .translate("No job posts available") ??
              "No Job Post Found"));
    }

    //  var designation = data["designationName"].toString();
    return SizedBox(
      height: MediaQuery.of(context).size.height * .56,
      child: ListView.builder(
          itemCount: filterdata.length,
          itemBuilder: (context, index) {
            return Container(
              height: 120,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(color: Colors.grey, spreadRadius: 3),
                ],
              ),
              child: InkWell(
                  onTap: () {
                    employee_add_count(filterdata[index].id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JobPosts(
                                  post: filterdata[index],
                                )));
                  },
                  child: ListTile(
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    tileColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/department.svg',
                                    semanticsLabel: 'My SVG Image',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(filterdata[index].departmentName!,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/designation.svg',
                                    semanticsLabel: 'My SVG Image',
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(filterdata[index].designationName!,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                                "${AppLocalizations.of(context)!.translate("Vacancy :") ?? "Vacancy :"}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.green)),
                            Text("${filterdata[index].numberOfEmp}")
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_city, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("${filterdata[index].employeerName}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  )),
            );
          }),
    );
  }

  employee_add_count(var id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var token = prefs.getString("token");
    var name = data["name"];
    var mobileNumber = data["mobileNumber"];
    //var datetime = DateTime.now();
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd/MM/yyyy HH:mm a').format(now);

    //  print(id);
    try {
      var body = {
        'name': name.toString(),
        'phoneNumber': mobileNumber.toString(),
        'currentDateAndTime': formattedDate.toString()
      };
      //   print(body);
      var response = await http.post(
          Uri.parse(
              "https://admin.job-pulse.com/api/viewjobs/employeeviewcount/${id}"),
          body: body,
          headers: {
            'Authorization': 'Bearer $token',
          });
      // print(response.body);
      //var data = json.decode(response.body);
      if (data["statusCode"] == 200) {
        // snackBar().display(context, "Job post updated Successfully", Colors.green);
      }
      //print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }
}

class Post {
  final String? ComapanyName;
  final String? MobileNo;
  final int? NoOfvacancy;
  final String? Address;
  final String? City;
  final double? destinationLatitude = 21.762398;
  final double? destinationLongitude = 72.122637;
  final int? price;
  final String? ManagerName;
  final int? CountOfCall;
  Post({
    required this.ComapanyName,
    required this.MobileNo,
    required this.NoOfvacancy,
    required this.Address,
    required this.City,
    required this.price,
    required this.ManagerName,
    required this.CountOfCall,
  });
}

class JobPosts extends StatefulWidget {
  JobPost? post;
  JobPosts({Key? key, this.post}) : super(key: key);

  @override
  State<JobPosts> createState() => _JobPostsState();
}

class _JobPostsState extends State<JobPosts> {
  // Sample list of Post objects
  List<Post> posts = [
    Post(
        ComapanyName: 'Company 1',
        MobileNo: '1234567890',
        NoOfvacancy: 10,
        Address: 'Sardarnagar, Bhavnagar',
        City: 'Bhavnagar',
        price: 10000,
        ManagerName: 'John Doe',
        CountOfCall: 100),
  ];

  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    return Scaffold(
        appBar: AppBar(
          title: Text(
              AppLocalizations.of(context)!.translate("Job Post Details") ??
                  "Job Post Details"),
        ),
        body: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                    .translate("Position Name:") ??
                                "Position Name",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!
                                        .translate(post!.designationName) ??
                                    post!.designationName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate("Vacancy :") ?? "Vacancy :"}  ${post.numberOfEmp}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.currency_rupee),
                              Text(
                                post.requirementTypes
                                    ? "${post.price}  ${AppLocalizations.of(context)!.translate("per piece") ?? "per piece"}"
                                    : "${post.salary}   ${AppLocalizations.of(context)!.translate("per month") ?? "per month"}",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.employeerName.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /*Container(
                            color: Colors.yellowAccent,
                            child: IconButton(
                              onPressed: () {
                                _showPhoneCallConfirmationDialog(
                                    post.mobileNumber.toString(), post.id);
                              },
                              icon: const Icon(
                                Icons.phone_android,
                                color: Colors.green,
                              ),
                            ),
                          ),*/

                          InkWell(
                              onTap: (){
                                _showPhoneCallConfirmationDialog(
                                    post.mobileNumber.toString(), post.id);
                              },
                              child: Icon(Icons.phone,color: Colors.green,)),
                          Text(
                            "  +91 ${post.mobileNumber.toString()}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  _openGoogleMaps(
                                      post.latitude, post.longitude);
                                },
                                child: Text(
                                  "${post.address}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.cityName.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            _openGoogleMaps(post.latitude, post.longitude);
                          },
                          child: Text(AppLocalizations.of(context)!
                                  .translate("Click to Navigate") ??
                              "Click to Navigate"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void _openGoogleMaps(destinationLatitude, destinationLongitude) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchPhoneCall(String phoneNumber) async {
    //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  void _showPhoneCallConfirmationDialog(String phoneNumber, var id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Make Phone Call"),
          content: Text("Do you want to call +91 $phoneNumber ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Call"),
              onPressed: () {
                Mobile_add_count(id);
                Navigator.of(context).pop(); // Close the dialog
                _launchPhoneCall(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  Mobile_add_count(var id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var token = prefs.getString("token");
    var name = data["name"];
    var mobileNumber = data["mobileNumber"];
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd/MM/yyyy HH:mm a').format(now);

    // print(id);
    try {
      var body = {
        'name': name.toString(),
        'phoneNumber': mobileNumber.toString(),
        'currentDateAndTime': formattedDate.toString()
      };
      // print(body);
      var response = await http.post(
          Uri.parse(
              "https://admin.job-pulse.com/api/viewjobs/mobileCallcount/${id}"),
          body: body,
          headers: {
            'Authorization': 'Bearer $token',
          });
      // print(response.body);
      //var data = json.decode(response.body);
      if (data["statusCode"] == 200) {
        // snackBar().display(context, "Job post updated Successfully", Colors.green);
      }
      //print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }
}
