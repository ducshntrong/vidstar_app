import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hình nền
          Positioned(
            left: 5,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255,
                    250,
                    45,
                    108),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 5,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Color(0xFF32d1ea),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          // Hình tròn ở giữa
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}

// class CustomIcon extends StatelessWidget {
//   const CustomIcon({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 45,
//       height: 30,
//       child: Stack(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(
//               left: 10,
//             ),
//             width: 38,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(
//                 255,
//                 250,
//                 45,
//                 108,
//               ),
//               borderRadius: BorderRadius.circular(7),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(
//               right: 10,
//             ),
//             width: 38,
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(
//                 255,
//                 32,
//                 211,
//                 234,
//               ),
//               borderRadius: BorderRadius.circular(7),
//             ),
//           ),
//           Center(
//             child: Container(
//               height: double.infinity,
//               width: 38,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(7),
//               ),
//               child: const Icon(
//                 Icons.add,
//                 color: Colors.black,
//                 size: 20,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
