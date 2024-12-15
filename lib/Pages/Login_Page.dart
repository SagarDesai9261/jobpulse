// ignore_for_file: use_build_context_synchronously
import 'package:job_pulse/Registraction_Pages/Register_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Registraction_Pages/Re-Register-employee.dart';
import '../Widget/custom_dialog_box.dart';
import '../Widget/snackbar.dart';
import '../main.dart';
import 'company/home_page.dart';
import 'employee/home_page.dart';

class LanguageService {
  static const String apiUrl = 'https://admin.job-pulse.com/api/language';

  Future<List<dynamic>> fetchLanguageCodes() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final languages = data['data'];

      return languages;
    } else {
      throw Exception('Failed to fetch language codes');
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _user;
  final formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isEmployee = false;
  Future<List>? _languages;
  bool _obscurePassword = true;
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _languages = LanguageService().fetchLanguageCodes();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Text(AppLocalizations.of(context)!.translate('Login') ?? "Login"),
          actions: [
            IconButton(
              onPressed: () {
                _showLanguageDialog(context);
              },
              icon: const Icon(Icons.language),
            ),
          ],
        ),
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    //  shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit
                          .cover, // You can change this property to control how the image is scaled
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: mobile,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.black,
                      ),
                      hintText: AppLocalizations.of(context)!
                              .translate('Enter your Mobile Number') ??
                          "Enter your Mobile Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Mobile is required';
                      } else if (value.length < 10) {
                        return "Mobile number is invalid";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: password,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.security,
                        color: Colors.black,
                      ),
                      hintText: AppLocalizations.of(context)!
                              .translate('Enter your password') ??
                          "Enter your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.topRight,
                    child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return MyAlertDialog();
                            },
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                                  .translate('Forgot Password') ??
                              "Forgot Password",
                          style: TextStyle(color: Colors.black),
                        ))),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () async {
                        //_onAlertButtonPressed(context);
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await login();
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Colors.black,
                            )
                          : Text(
                              AppLocalizations.of(context)!
                                      .translate('Login') ??
                                  "Login",
                              style: const TextStyle(fontSize: 18.0),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    _handleSignIn();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: Text(AppLocalizations.of(context)!
                          .translate('Sign in with Google') ??
                      "Sign in with Google"),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                              .translate('Create New Account....') ??
                          "Create New account....",
                      style: const TextStyle(fontSize: 14),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()));
                      },
                      child: Text(
                        AppLocalizations.of(context)!
                                .translate('Register Now') ??
                            "Register now",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    var response = await http.post(
        Uri.parse("https://admin.job-pulse.com/api/employee/login"),
        body: {"mobileNumber": mobile.text, "password": password.text});
    Map<String, dynamic> data = json.decode(response.body);

    if (data["statusCode"] == 403) {
      final response1 = await http.post(
          Uri.parse("https://admin.job-pulse.com/api/company/login"),
          body: {"mobileNumber": mobile.text, "password": password.text});
      var jsonResponse = jsonDecode(response1.body);

      if (jsonResponse['statusCode'] == 402 ||
          jsonResponse['statusCode'] == 500 ||
          jsonResponse['statusCode'] == 403) {
        snackBar s = snackBar();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "Your Profile is Rejected",
                descriptions: "Reason :- ${jsonResponse['deniedReason']}",
                text: "Yes",
              );
            });
        //s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
        setState(() {
          _isLoading = false;
        });
      } else if (jsonResponse["statusCode"] == 401 ||
          data["statusCode"] == 401) {
        _onAlertButtonPressed(context);
        setState(() {
          _isLoading = false;
        });
      } else {
        Map<String, dynamic> decodeToken =
            JwtDecoder.decode(jsonResponse["token"]);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_details', jsonEncode(decodeToken));
        await prefs.setString("isLogin", "Yes");
        await prefs.setString("isEmployee", "false");
        await prefs.setString("token", jsonResponse["token"]);
        var _id = decodeToken["_id"];
       print(decodeToken);
         await prefs.setString("name", decodeToken["companyName"]);
        await prefs.setString("employeeImage", decodeToken["companyImage"]??"");
        await prefs.setString("mobileNumber", decodeToken["mobileNumber"].toString());
        final String apiUrl = 'https://admin.job-pulse.com/api/company/${_id}';
        var token = jsonResponse["token"];
        var notificationtoken = prefs.getString("NotificationToken");
        final Map<String, dynamic> datatoken = {
          'token': notificationtoken.toString()
        };
        var response2 = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(datatoken),
        );
        if (response2.statusCode == 200) {
          snackBar().display(context, "Login Successfully", Colors.green);

          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => Home_Page_company()));
        }
      }
    } else if (data["statusCode"] == 402) {
      snackBar s = snackBar();
      List reson = data["deniedReason"];
      print(reson.length);
      //s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: "Your Profile is Rejected",
              descriptions:
                  "Reason :- ${data["deniedReason"][reson.length - 1]}",
              text: "Yes",
              mobile: mobile.text,
            );
          });
      // s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
      setState(() {
        _isLoading = false;
      });
    } else if (data["statusCode"] == 401 || data["statusCode"] == 406) {
      _onAlertButtonPressed(context);
    } else if (data["statusCode"] == 405) {
      snackBar s = snackBar();
      s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
      // _onAlertButtonPressed(context);
    } else if (data["statusCode"] == 200) {
      var jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> decodeToken =
          JwtDecoder.decode(jsonResponse["token"]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_details', jsonEncode(decodeToken));
      await prefs.setString("isEmployee", "true");
      await prefs.setString("isLogin", "Yes");
      await prefs.setString("token", jsonResponse["token"]);
      var _id = decodeToken["_id"];

      await prefs.setString("name", decodeToken["name"]);
      await prefs.setString("employeeImage", decodeToken["employeeImage"]??"");
      await prefs.setString("mobileNumber", decodeToken["mobileNumber"].toString());
      final String apiUrl = 'https://admin.job-pulse.com/api/employee/${_id}';
      var token = jsonResponse["token"];
      var notificationtoken = prefs.getString("NotificationToken");
      final Map<String, dynamic> datatoken = {
        'token': notificationtoken.toString()
      };
      var response2 = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(datatoken),
      );
      if (response2.statusCode == 200) {
        snackBar().display(context, "Login Successfully", Colors.green);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home_page_employee()));
      }
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)!.translate('select_language') ??
                  "Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<dynamic>>(
                future: _languages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final List? languages = snapshot.data;

                    return Column(
                      children: [
                        for (var i in languages!) ...[
                          _buildLanguageButton(
                              context, Locale(i["code"]), i["name"])
                        ]
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(
      BuildContext context, Locale locale, String language) {
    return TextButton(
      onPressed: () async {
        AppLocalizations.of(context)!.setLocale(locale);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedLanguage', locale.languageCode);
        setState(() {});
        Navigator.pop(context); // Close the dialog
      },
      child:
          Text(AppLocalizations.of(context)!.translate(language) ?? language),
    );
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      setState(() {
        _user = user;
      });
    } catch (error) {
      print("Google Sign-In Error: $error");
    }
  }

  _onAlertButtonPressed(context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: AppLocalizations.of(context)!.translate('Under Verifing') ??
          "Under Verifing",
      desc: AppLocalizations.of(context)!
              .translate('Your Profile is under Verifing') ??
          "Your Profile is under Verifing",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}

class MyAlertDialog extends StatefulWidget {
  @override
  _MyAlertDialogState createState() => _MyAlertDialogState();
}

class _MyAlertDialogState extends State<MyAlertDialog> {
  bool _passwordVisible = true;
  bool _passwordVisible1 = true;
  bool _isloading = false;
  bool _isEmployee = true;
  final formkey = GlobalKey<FormState>();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _aadharController = TextEditingController();
  TextEditingController _gstController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String message = "";
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.translate('Forgot Password') ??
            "Forgot Password",
      ),
      content: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEmployee ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmployee = true;
                      });
                    },
                    child: Text(
                        AppLocalizations.of(context)!.translate('Employee') ??
                            "Employee"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isEmployee ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmployee = false;
                      });
                    },
                    child: Text(
                        AppLocalizations.of(context)!.translate('Company') ??
                            "Company"),
                  ),
                ],
              ),
              TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Mobile is required';
                  } else if (value.length < 10) {
                    return "Mobile number is invalid";
                  }
                  return null;
                },
                controller: _mobileController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                          .translate('Mobile Number') ??
                      "Mobile Number",
                  icon: Icon(Icons.phone),
                ),
              ),
              _isEmployee
                  ? TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Aadhar Number is required';
                        } else if (value.length < 10) {
                          return "Aadhar number is invalid";
                        }
                        return null;
                      },
                      controller: _aadharController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                                .translate('Aadhar Number') ??
                            "Aadhar Number",
                        icon: Icon(Icons.assignment_ind),
                      ),
                    )
                  : TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'GST Number is required';
                        } else if (value.length < 14) {
                          return "GST number is invalid";
                        }
                        return null;
                      },
                      controller: _gstController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                                .translate('GST Number') ??
                            "GST Number",
                        icon: Icon(Icons.assignment_ind),
                      ),
                    ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translate('New Password') ??
                          "New Password",
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: _passwordVisible,
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Confirm password is required';
                  } else if (value != _passwordController.text) {
                    return "Both Password is not match";
                  }
                  return null;
                },
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                          .translate('Confirm Password') ??
                      "Confirm Password",
                  icon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible1
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible1 = !_passwordVisible1;
                      });
                    },
                  ),
                ),
                obscureText: _passwordVisible1,
              ),
              SizedBox(
                height: 20,
              ),
              message == "Password change Successfully"
                  ? Text(
                      message,
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    )
                  : Text(message,
                      style: TextStyle(fontSize: 14, color: Colors.red))
            ],
          ),
        ),
      ),
      actions: <Widget>[
        SizedBox(
          height: 50,
          width: 100,
          child: ElevatedButton(
            onPressed: () async {
              if (formkey.currentState!.validate()) {
                setState(() {
                  _isloading = true;
                });
                if (_isEmployee == true) {
                  var response = await http.put(
                      Uri.parse(
                          "https://admin.job-pulse.com/api/employee_forgot_password"),
                      body: {
                        "mobileNumber": _mobileController.text,
                        "adharNumber": _aadharController.text,
                        "password": _passwordController.text
                      });
                  Map<String, dynamic> data = json.decode(response.body);
                  if (data["statusCode"] == 200) {
                    setState(() {
                      message = "Password change Successfully";
                      _isloading = false;
                    });
                  } else {
                    setState(() {
                      _isloading = false;
                      message = "Mobile and aadhar not match";
                    });
                  }
                } else {
                  var response = await http.put(
                      Uri.parse(
                          "https://admin.job-pulse.com/api/company_forgot_password"),
                      body: {
                        "mobileNumber": _mobileController.text,
                        "gstNumber": _gstController.text,
                        "password": _passwordController.text
                      });
                  Map<String, dynamic> data = json.decode(response.body);
                  if (data["statusCode"] == 200) {
                    setState(() {
                      message = "Password change Successfully";
                      _isloading = false;
                    });
                  } else {
                    setState(() {
                      _isloading = false;
                      message = "Mobile and Gst Number is not match";
                    });
                  }
                }
              }

              //Navigator.pop(context);
            },
            child: _isloading == false
                ? Text('Submit')
                : CircularProgressIndicator(
                    color: Colors.white,
                  ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
