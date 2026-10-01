import 'package:core/src/model/assignment.dart';
import 'package:core/src/validator/violation.dart';

/// Ж2. Зал не занят двумя группами в один слот.
List<Violation> checkRoomConflicts(List<Assignment> schedule) {
  final List<Violation> violation = [];
  final Map<(int, int), List<Assignment>> map = {};

  for (final a in schedule) {
    final key = (a.roomId, a.slotId);
    map.putIfAbsent(key, () => []).add(a);
  }

  for (var value in map.values) {
    //? вместо проверки на длину, решил, использовать его
    if (value.length > 1) {
      violation.add(Violation(HardConstraint.zh2, value));
    }
  }

  return violation;
}
