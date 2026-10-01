import 'package:core/src/model/assignment.dart';

enum HardConstraint { zh1, zh2, zh3, zh4, zh5, zh6, zh7, zh8 }

final class Violation {
  final HardConstraint constraint;
  final List<Assignment> assignments;

  const Violation(this.constraint, this.assignments);
}
