import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:saturday_practise/Admin/admin_main_screen.dart';
import 'package:saturday_practise/Screens/signup_screen.dart';
import 'package:saturday_practise/Screens/user_screen.dart';

import '../Custom_Widgets/custom_textfiled.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  bool visible = true;

    @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }

   Future login() async{
    if (_formKey.currentState!.validate()) {
      await _auth.signInWithEmailAndPassword(
          email: loginEmailController.text.trim(),
          password: loginPasswordController.text.trim(),
      ).then((value) {
        String name = 'tapan@gmail.com';
        String password = 'Tapan@708';
        if(loginEmailController.text.trim() == name.trim() || loginPasswordController.text.trim() == password.trim()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AdminMainScreen()));
        }
        else{
          Fluttertoast.showToast(
            msg: 'Login Sucessfully',
            fontSize: 15,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            gravity: ToastGravity.BOTTOM,
          );
          loginEmailController.clear();
          loginPasswordController.clear();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> UserMainScreen()));
        }
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(
          msg: 'Sorry!!Somethink Went Wrong',
          fontSize: 15,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.black,
          gravity: ToastGravity.BOTTOM,
        );
        loginEmailController.clear();
        loginPasswordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Login Page'),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  labeltext: 'Enter your email',
                  controller: loginEmailController,
                  textInputType: TextInputType.emailAddress,
                  validator: (value) {
                    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
                    final regExp = RegExp(pattern);
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!regExp.hasMatch(value)) {
                      return 'Enter a valid email format';
                    }
                    return null;
                  },
                ),
                Padding(
                     padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: loginPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      obscureText: visible,
                          decoration: InputDecoration(
                            label: Text('Enter your password'),
                            suffixIcon: IconButton(onPressed: (){
                               setState(() {
                                 visible = !visible;
                               });
                            }, icon: visible ? Icon(Icons.visibility_off) : Icon(Icons.visibility)),
                            border: OutlineInputBorder()
                          ),
                     ),
                )
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: login,
            child: Text('Login'),
          ),
          SizedBox(height: 17,),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Colors.black,fontSize: 18), // style for the normal text
                children: [
                  TextSpan(
                    text: 'Signup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ), // style for the "Signup" text
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signuppage()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}