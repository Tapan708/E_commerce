import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Custom_Widgets/custom_textfiled.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore userdata = FirebaseFirestore.instance;
  bool first_visible = true;
  bool second_visible = true;
  TextEditingController signupEmail = TextEditingController();
  TextEditingController signupName = TextEditingController();
  TextEditingController signupMobile = TextEditingController();
  TextEditingController signupPassword = TextEditingController();

  @override
  void dispose() {
    signupPassword.dispose();
    signupEmail.dispose();
    signupMobile.dispose();
    signupName.dispose();
    super.dispose();
  }
  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
        await _auth.createUserWithEmailAndPassword(
            email: signupEmail.text.trim(),
            password: signupPassword.text.trim()
        ).then((value) async {
          Fluttertoast.showToast(
              msg: 'User Registered Sucessfully',
              fontSize: 15,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.black,
              gravity: ToastGravity.BOTTOM,
          );
          await userdata.collection('users').doc(_auth.currentUser!.uid).set({
            'id' : _auth.currentUser!.uid,
            'name': signupName.text.trim(),
            'email': signupEmail.text.trim(),
            'mobile': signupMobile.text.trim(),
            'password': signupPassword.text.trim(),
          });
          signupEmail.clear();
          signupPassword.clear();
          signupName.clear();
          signupMobile.clear();
          Navigator.pop(context);
        }).onError((error, stackTrace) {
          Fluttertoast.showToast(
            msg: 'Sorry!!Somethink Went Wrong',
            fontSize: 15,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.black,
            gravity: ToastGravity.BOTTOM,
          );
          signupEmail.clear();
          signupPassword.clear();
          signupName.clear();
          signupMobile.clear();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Sign Up'),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  labeltext: 'Enter Your Name',
                  controller: signupName,
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name cannot be empty';
                    } else if (value.length < 3) {
                      return 'Name must be at least 3 letters long';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  digit: 10,
                  labeltext: 'Enter Your phone number',
                  controller: signupMobile,
                  textInputType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  labeltext: 'Enter Your Email',
                  controller: signupEmail,
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
                    controller: signupPassword,
                    validator: (value) {
                      const pattern = r'^(?=.*[A-Za-z])(?=.*[!@#\$&*~]).{8,16}$';
                      final regExp = RegExp(pattern);
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (!regExp.hasMatch(value)) {
                        return 'Password must be 8-16 characters long, contain at least one letter and one special character';
                      }
                      return null;
                    },
                    obscureText: first_visible,
                    decoration: InputDecoration(
                        label: Text('Enter your password'),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            first_visible = !first_visible;
                          });
                        }, icon: first_visible ? Icon(Icons.visibility_off) : Icon(Icons.visibility)),
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                       if (value != signupPassword.text) {
                        return 'Please enter correct password';
                      }
                    },
                    obscureText: second_visible,
                    decoration: InputDecoration(
                        label: Text('Enter Confirm password'),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            second_visible = !second_visible;
                          });
                        }, icon: second_visible ? Icon(Icons.visibility_off) : Icon(Icons.visibility)),
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: signUp,
            child: Text('Signup'),
          ),
          SizedBox(height: 17,),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: TextStyle(color: Colors.black,fontSize: 18), // style for the normal text
                children: [
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context);
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
