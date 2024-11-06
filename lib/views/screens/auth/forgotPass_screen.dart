import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/views/screens/auth/signup_screen.dart';
import 'package:vidstar_app/views/widgets/text_input_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              'Forgot Password',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextInputField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0866FF), Color(0xFF00BFFF)], // Màu gradient
                  begin: Alignment.centerLeft, // Điểm bắt đầu của gradient
                  end: Alignment.centerRight, // Điểm kết thúc của gradient
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Obx(() {
                return InkWell(
                  onTap: () {
                    if (!authController.isLoading.value) {
                      authController.resetPassword(_emailController.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Center(
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Đổi màu cho CircularProgressIndicator
                    )
                        : const Text(
                      'Send Reset Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Đổi màu chữ thành trắng để nổi bật trên nền gradient
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remembered your password? ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(), // Trở về trang đăng nhập
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
    );
  }
}

