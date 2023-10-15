import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';
import '../services/auth_services.dart';

class RegisterPage extends StatefulWidget {
  final Function() onTap;
  const RegisterPage({@required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Passwords do not match!'),
        );
      },
    );
  }

  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Lottie.asset(
              'lib/images/loading.json',
              height: 200,
            ),
          );
        });

    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          'userName': emailController.text.split('@')[0],
          'bio': 'Empty bio',
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'uid': FirebaseAuth.instance.currentUser.uid,
          'cards': FieldValue.arrayUnion([]),
          'userAvatar': ''
        });

        // addUserDetails(
        //   firstNameController.text,
        //    lastNameController.text,
        //    emailController.text);
        //  } else{
        showErrorMessage();
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        showErrorMessage();
      } else if (e.code == 'wrong-password') {
        showErrorMessage();
      }
    }
  }

  // Future addUserDetails(String firstName, String lastName, String email) async{
  //   await FirebaseFirestore.instance.collection('users').add({
  //     'first name': firstName,
  //     'last name': lastName,
  //     'email': email,
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    SizedBox(height: 20.w),
                    // const Icon(
                    //   Icons.person,
                    //   size: 100,
                    //   ),

                    const SizedBox(height: 50),

                    Padding(
                      padding: const EdgeInsets.only(left: 22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign up',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10.w),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Let's create an account for you!",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    MyTextField(
                      controller: firstNameController,
                      hintText: "First Name",
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    MyTextField(
                      controller: lastNameController,
                      hintText: "Last Name",
                      obscureText: false,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    MyTextField(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    MyTextField(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      obscureText: true,
                    ),

                    const SizedBox(
                      height: 25.0,
                    ),

                    MyButton(
                      text: "Sign up",
                      onTap: signUserUp,
                    ),

                    const SizedBox(
                      height: 50.0,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[500],
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.blue[700],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
