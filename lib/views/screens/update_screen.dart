import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Thư viện để định dạng ngày tháng
import 'dart:io'; // Thư viện để sử dụng File
import '../../controllers/auth_controller.dart';

class UpdateScreen extends StatelessWidget {
  final AuthController authController = AuthController.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final RxBool isFormValid = false.obs; // Biến trạng thái để ktra form

  @override
  Widget build(BuildContext context) {
    String uid = authController.user.uid;

    // Hàm ktra form
    void validateForm() {
      isFormValid.value = nameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          birthDateController.text.isNotEmpty &&
          genderController.text.isNotEmpty;
    }

    // Lắng nghe thay đổi văn bản
    nameController.addListener(validateForm);
    phoneController.addListener(validateForm);
    birthDateController.addListener(validateForm);
    genderController.addListener(validateForm);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Khởi tạo gtri cho các trường từ thông tin user hiện tại
          nameController.text = userData['name'] ?? '';
          phoneController.text = userData['phoneNumber'] ?? '';
          birthDateController.text = userData['birthDate'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(userData['birthDate']))
              : '';
          genderController.text = userData['gender'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Obx(() {
                        return CircleAvatar(
                          radius: 64,
                          backgroundImage: authController.profilePhoto != null
                              ? FileImage(authController.profilePhoto!)
                              : NetworkImage(userData['profilePhoto'] ?? 'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png')
                          as ImageProvider,
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
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, "Name", authController.isLoading),
                  const SizedBox(height: 10),
                  _buildTextField(phoneController, "Phone Number", authController.isLoading, keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  _buildDateField(context, birthDateController, authController.isLoading),
                  const SizedBox(height: 10),
                  _buildGenderDropdown(authController.isLoading),
                  const SizedBox(height: 20),
                  Obx(() {
                    return ElevatedButton(
                      onPressed: authController.isLoading.value || !isFormValid.value
                          ? null // Ngăn thao tác khi đang loading or form k hợp lệ
                          : () async {
                        authController.isLoading.value = true; // Bắt đầu loading
                        await authController.updateUser(
                          name: nameController.text,
                          phoneNumber: phoneController.text,
                          birthDate: birthDateController.text.isNotEmpty
                              ? DateTime.parse(birthDateController.text)
                              : null,
                          gender: genderController.text,
                          profilePhoto: authController.profilePhoto,
                        );

                        authController.isLoading.value = false; // Kết thúc loading
                        Navigator.pop(context);
                      },
                      child: authController.isLoading.value
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                          : const Text("Update"),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, RxBool isLoading, {TextInputType keyboardType = TextInputType.text}) {
    return AbsorbPointer(
      absorbing: isLoading.value,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: controller.text.isEmpty ? '$label is required' : null,
        ),
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.phone ? [FilteringTextInputFormatter.digitsOnly] : [],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, RxBool isLoading) {
    return AbsorbPointer(
      absorbing: isLoading.value,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Birth Date (YYYY-MM-DD)",
          border: const OutlineInputBorder(),
          errorText: controller.text.isEmpty ? 'Birth date is required' : null,
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }

  Widget _buildGenderDropdown(RxBool isLoading) {
    return AbsorbPointer(
      absorbing: isLoading.value,
      child: DropdownButtonFormField<String>(
        value: genderController.text.isNotEmpty ? genderController.text : null,
        decoration: InputDecoration(
          labelText: "Gender",
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          errorText: genderController.text.isEmpty ? 'Gender is required' : null,
        ),
        items: const [
          DropdownMenuItem(value: 'male', child: Text('Male')),
          DropdownMenuItem(value: 'female', child: Text('Female')),
          DropdownMenuItem(value: 'other', child: Text('Other')),
        ],
        onChanged: (value) {
          genderController.text = value ?? '';
          isFormValid.value = nameController.text.isNotEmpty &&
              phoneController.text.isNotEmpty &&
              birthDateController.text.isNotEmpty &&
              genderController.text.isNotEmpty;
        },
      ),
    );
  }
}
