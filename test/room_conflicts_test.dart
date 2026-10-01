import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('Ж2: checkRoomConflicts', () {
    test('две группы в одном зале в один слот — одно нарушение', () {
      final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);
      final a2 = Assignment(groupId: 2, roomId: 1, slotId: 1);

      final result = checkRoomConflicts([a1, a2]);

      expect(result, hasLength(1));
      expect(result.single.constraint, HardConstraint.zh2);
      expect(result.single.assignments, unorderedEquals([a1, a2]));
    });

    test('две группы в разных залах в один слот — нет нарушения', () {
      final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);
      final a2 = Assignment(groupId: 2, roomId: 2, slotId: 1);

      final result = checkRoomConflicts([a1, a2]);

      expect(result, isEmpty);
    });

    test('две одинаковые группы в одном зале в один слот — одно нарушение', () {
      final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);
      final a2 = Assignment(groupId: 1, roomId: 1, slotId: 1);

      final result = checkRoomConflicts([a1, a2]);

      expect(result, hasLength(1));
      expect(result.single.constraint, HardConstraint.zh2);
      expect(result.single.assignments, unorderedEquals([a1, a2]));
    });

    test('пустое расписание — нет нарушения', () {
      final result = checkRoomConflicts([]);
      expect(result, isEmpty);
    });

    test('одно назначение — нет нарушения', () {
      final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);

      final result = checkRoomConflicts([a1]);

      expect(result, isEmpty);
    });

    test(
      'один зал, разные слоты — нет нарушения',
      () {
        final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);
        final a2 = Assignment(groupId: 1, roomId: 1, slotId: 2);

        final result = checkRoomConflicts([a1, a2]);

        expect(result, isEmpty);
      },
    );

    test('три группы в одном зале в один слот — одно нарушение', () {
      final a1 = Assignment(groupId: 1, roomId: 1, slotId: 1);
      final a2 = Assignment(groupId: 2, roomId: 1, slotId: 1);
      final a3 = Assignment(groupId: 3, roomId: 1, slotId: 1);

      final result = checkRoomConflicts([a1, a2, a3]);

      expect(result, hasLength(1));
      expect(result.single.constraint, HardConstraint.zh2);
      expect(result.single.assignments, unorderedEquals([a1, a2, a3]));
    });
  });
}
