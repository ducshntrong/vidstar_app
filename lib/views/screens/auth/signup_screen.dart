import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/auth_controller.dart';
import 'package:vidstar_app/views/screens/auth/login_screen.dart';
import 'package:vidstar_app/views/widgets/text_input_field.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [Color(0xFF0866FF), Color(0xFF00BFFF)],
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'VidStar',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      // Không cần chỉ định màu ở đây vì gradient sẽ thay thế
                    ),
                  ),
                ),
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Stack(
                  children: [
                    Obx(() {
                      return CircleAvatar(
                        radius: 64,
                        backgroundImage: authController.profilePhoto != null
                            ? FileImage(authController.profilePhoto!) // Hiển thị hình ảnh đã chọn
                            : const NetworkImage(
                            'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png'),
                        backgroundColor: Colors.black,
                      );
                    }),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () => authController.pickImage(),
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: _usernameController,
                    labelText: 'Username',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: _emailController,
                    labelText: 'Email',
                    icon: Icons.email,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextInputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    icon: Icons.lock,
                    isObscure: true,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0866FF), Color(0xFF00BFFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Obx(
                        () => InkWell(
                      onTap: () {
                        if (!authController.isLoading.value) {
                          authController.registerUser(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                            authController.profilePhoto,
                          );
                        }
                      },
                      child: Center(
                        child: authController.isLoading.value
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Color(0xFF4E8DF8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
