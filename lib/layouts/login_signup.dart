import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../components/common/custom_snackbar.component.dart';
import '../components/common/text.component.dart';
import '../providers/auth.provider.dart';
import '../utilities/theme/color_data.dart';

class LoginSignupPage extends ConsumerStatefulWidget {
  const LoginSignupPage({super.key});

  @override
  ConsumerState<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends ConsumerState<LoginSignupPage> {
  bool isLogin = true;
  // bool usePhone = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((elapsed) {
      setState(() {
        _elapsed = elapsed;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void toggleLogin() {
    setState(() {
      isLogin = !isLogin;
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      phoneController.clear();
      // usePhone = false;
    });
  }

  void toggleLoginType(bool phone) {
    setState(() {
      // usePhone = phone;
      emailController.clear();
    });
  }

  void login() async {
    // if (usePhone) {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      CustomSnackBar.log(
        message: 'Please fill in all fields',
        status: SnackBarType.error,
      );
      return;
    }
    ref
        .read(authProvider.notifier)
        .signInWithPhone(
          phone: phoneController.text,
          password: passwordController.text,
        );
    return;
    // }
    // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    //   CustomSnackBar.log(
    //     message: 'Please fill in all fields',
    //     status: SnackBarType.error,
    //   );
    //   return;
    // }
    // ref
    //     .read(authProvider.notifier)
    //     .signIn(email: emailController.text, password: passwordController.text);
  }

  void signup() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        nameController.text.isEmpty) {
      CustomSnackBar.log(
        message: 'Please fill in all fields',
        status: SnackBarType.error,
      );
      return;
    }
    ref
        .read(authProvider.notifier)
        .signUp(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          phone: phoneController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final colorData = CustomColorData.from(ref);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          ShaderBuilder(assetKey: 'assets/shaders/wrap.frag', (
            BuildContext context,
            FragmentShader shader,
            _,
          ) {
            return ShaderMask(
              shaderCallback: (Rect bounds) {
                shader.setFloat(0, bounds.width * 5);
                shader.setFloat(1, bounds.height * 5);
                shader.setFloat(2, _elapsed.inMilliseconds.toDouble() / 1000);
                return shader;
              },
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
              ),
            );
          }),
          Positioned(
            top: height * .15,
            left: width * .075,
            child: Container(
              width: width * .85,
              padding: EdgeInsets.symmetric(
                horizontal: width * .045,
                vertical: height * .02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/icons/logo.png",
                      height: aspectRatio * 120,
                      width: aspectRatio * 120,
                    ),
                  ),
                  SizedBox(height: height * .02),
                  CustomText(
                    text:
                        isLogin
                            ? "Sign in to your account"
                            : "Create your account",
                    size: aspectRatio * 40,
                    color: colorData.fontColor(1),
                  ),
                  SizedBox(height: height * .02),
                  // AuthProviderButton(
                  //   function: () {},
                  //   text: "Sign ${isLogin ? "in" : "up"} with Google",
                  //   iconPath: "assets/icons/google.png",
                  // ),
                  // SizedBox(height: height * .025),
                  // if (isLogin)
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () => toggleLoginType(false),
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //             vertical: 6,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color:
                  //                 !usePhone
                  //                     ? colorData.secondaryColor(.2)
                  //                     : Colors.transparent,
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: CustomText(
                  //             text: "Email",
                  //             size: aspectRatio * 25,
                  //             color: colorData.fontColor(!usePhone ? 1 : .5),
                  //             weight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 8),
                  //       GestureDetector(
                  //         onTap: () => toggleLoginType(true),
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //             vertical: 6,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color:
                  //                 usePhone
                  //                     ? colorData.secondaryColor(.2)
                  //                     : Colors.transparent,
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: CustomText(
                  //             text: "Phone No",
                  //             size: aspectRatio * 25,
                  //             color: colorData.fontColor(usePhone ? 1 : .5),
                  //             weight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  if (isLogin) SizedBox(height: height * .025),
                  if (!isLogin)
                    AuthTextField(
                      controller: nameController,
                      hintText: "Full Name",
                      isFirst: true,
                    ),
                  // if (isLogin && usePhone)
                  if (isLogin)
                    AuthTextField(
                      controller: phoneController,
                      hintText: "Phone number",
                      needValidation: false,
                      isNumber: true,
                      isFirst: isLogin,
                    ),
                  // if (!usePhone && isLogin)
                  //   AuthTextField(
                  //     controller: emailController,
                  //     hintText: "Email address",
                  //     needValidation: !isLogin,
                  //     isFirst: isLogin,
                  //   ),
                  if (!isLogin)
                    AuthTextField(
                      controller: emailController,
                      hintText: "Email address",
                      needValidation: !isLogin,
                      isFirst: false,
                    ),
                  if (!isLogin)
                    AuthTextField(
                      controller: phoneController,
                      hintText: "Phone number",
                      needValidation: false,
                      isNumber: true,
                      isFirst: false,
                    ),
                  AuthTextField(
                    controller: passwordController,
                    hintText: "Password",
                    needValidation: !isLogin,
                    isLast: true,
                  ),
                  SizedBox(height: height * .02),
                  if (isLogin)
                    CustomText(
                      text: "Forgot password?",
                      decoration: TextDecoration.underline,
                      size: aspectRatio * 26,
                    ),
                  SizedBox(height: height * .02),
                  GestureDetector(
                    onTap: () {
                      isLogin ? login() : signup();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: aspectRatio * 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorData.highlightColor(),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        text: "Continue",
                        size: aspectRatio * 30,
                        weight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: height * .05,
            left: width * .075,
            right: width * .075,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: isLogin ? "Not a member?" : "Already an member?",
                  size: aspectRatio * 28,
                  color: colorData.fontColor(.8),
                  weight: FontWeight.w600,
                ),
                SizedBox(width: width * .02),
                GestureDetector(
                  onTap: toggleLogin,
                  child: CustomText(
                    text: isLogin ? "Create an account" : "Login here",
                    size: aspectRatio * 30,
                    color: colorData.fontColor(),
                    weight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthTextField extends ConsumerStatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.needValidation = false,
    this.isFirst = false,
    this.isLast = false,
    this.isNumber = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool needValidation;
  final bool isFirst;
  final bool isLast;
  final bool isNumber;

  @override
  ConsumerState<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends ConsumerState<AuthTextField> {
  bool isVisisble = false;
  bool showValidationMessage = true;

  void toggleVisibility() {
    setState(() {
      isVisisble = !isVisisble;
    });
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double width = MediaQuery.of(context).size.width;

    final colorData = CustomColorData.from(ref);
    bool isPassword = widget.hintText == "Password";
    bool isEmail = widget.hintText == "Email address";

    bool isEmailValid = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    ).hasMatch(widget.controller.text);
    bool isPasswordValid = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(widget.controller.text);

    String getPasswordValidationMessage() {
      String message = '';
      // if (!RegExp(r'^(?=.*[a-z])').hasMatch(widget.controller.text)) {
      //   message += '1 lowercase letter, ';
      // }
      // if (!RegExp(r'^(?=.*[A-Z])').hasMatch(widget.controller.text)) {
      //   message += '1 uppercase letter, ';
      // }
      // if (!RegExp(r'^(?=.*\d)').hasMatch(widget.controller.text)) {
      //   message += '1 number, ';
      // }
      // if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(widget.controller.text)) {
      //   message += '1 special character, ';
      // }
      if (widget.controller.text.length < 8) {
        message += 'minimum 6 characters, ';
      }
      return message.isNotEmpty
          ? 'Password needs: ${message.substring(0, message.length - 2)}'
          : 'Strong password';
    }

    return Container(
      padding: EdgeInsets.only(left: width * .04),
      decoration: BoxDecoration(
        borderRadius:
            widget.isFirst
                ? const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                )
                : widget.isLast
                ? const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                )
                : null,
        border: Border(
          top:
              widget.isFirst
                  ? BorderSide(color: colorData.secondaryColor(), width: 2)
                  : BorderSide.none,
          bottom: BorderSide(color: colorData.secondaryColor(), width: 2),
          left: BorderSide(color: colorData.secondaryColor(), width: 2),
          right: BorderSide(color: colorData.secondaryColor(), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: aspectRatio * 28,
              color: colorData.fontColor(.8),
            ),
            obscureText: isPassword && !isVisisble,
            keyboardType:
                isPassword
                    ? TextInputType.visiblePassword
                    : isEmail
                    ? TextInputType.emailAddress
                    : widget.isNumber
                    ? TextInputType.number
                    : TextInputType.text,
            cursorColor: Colors.blueAccent,
            onChanged: (value) {
              if (!showValidationMessage) {
                setState(() {
                  showValidationMessage = true;
                });
              }
            },
            onSubmitted: (value) {
              if ((isEmail && isEmailValid) ||
                  (isPassword && isPasswordValid)) {
                setState(() {
                  showValidationMessage = false;
                });
              }
            },

            decoration: InputDecoration(
              suffixIcon:
                  isPassword
                      ? GestureDetector(
                        onTap: toggleVisibility,
                        child: Icon(
                          !isVisisble ? Icons.visibility : Icons.visibility_off,
                          color: colorData.fontColor(.5),
                        ),
                      )
                      : null,
              contentPadding:
                  isPassword
                      ? EdgeInsets.only(top: aspectRatio * 30)
                      : EdgeInsets.zero,
              border: InputBorder.none,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: aspectRatio * 28,
                color: colorData.fontColor(.3),
              ),
            ),
          ),
          if (isEmail &&
              widget.controller.text.isNotEmpty &&
              showValidationMessage &&
              widget.needValidation)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isEmailValid ? 'Valid email address' : 'Invalid email address',
                style: TextStyle(
                  fontSize: aspectRatio * 20,
                  color: isEmailValid ? Colors.green : Colors.red,
                ),
              ),
            ),
          if (isPassword &&
              widget.controller.text.isNotEmpty &&
              showValidationMessage &&
              widget.needValidation)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                getPasswordValidationMessage(),
                style: TextStyle(
                  fontSize: aspectRatio * 20,
                  color: isPasswordValid ? Colors.green : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AuthProviderButton extends ConsumerWidget {
  const AuthProviderButton({
    super.key,
    required this.text,
    required this.function,
    required this.iconPath,
  });

  final String text;
  final Function function;
  final String iconPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double width = MediaQuery.of(context).size.width;

    final colorData = CustomColorData.from(ref);
    return GestureDetector(
      onTap: () => function,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: aspectRatio * 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorData.secondaryColor()),
          color: colorData.secondaryColor(.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: aspectRatio * 36,
              width: aspectRatio * 36,
            ),
            SizedBox(width: width * .03),
            CustomText(text: text),
          ],
        ),
      ),
    );
  }
}
