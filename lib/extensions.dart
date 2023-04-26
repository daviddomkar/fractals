import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

extension QuaternionExtension on Quaternion {
  // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
  Vector3 toEuler() {
    // yaw (x-axis rotation)
    double sinrCosp = 2 * (w * x + y * z);
    double cosrCosp = 1 - 2 * (x * x + y * y);
    double yaw = atan2(sinrCosp, cosrCosp);

    // pitch (y-axis rotation)
    double sinp = sqrt(1 + 2 * (w * y - x * z));
    double cosp = sqrt(1 - 2 * (w * y - x * z));
    double pitch = 2 * atan2(sinp, cosp) - pi / 2;

    // roll (z-axis rotation)
    double sinyCosp = 2 * (w * z + x * y);
    double cosyCosp = 1 - 2 * (y * y + z * z);
    double roll = atan2(sinyCosp, cosyCosp);

    return Vector3(degrees(yaw), degrees(pitch), degrees(roll));
  }
}
