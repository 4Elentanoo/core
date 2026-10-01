final class Assignment {
  final int groupId;
  final int roomId;
  final int slotId;

  const Assignment({
    required this.groupId,
    required this.roomId,
    required this.slotId,
  });

  @override
  bool operator ==(Object other) {
    //? super -> object, предполагаю, что все классы
    //? наследуются от класса Object
    //? old version -> super == other
    return identical(this, other) ||
        other is Assignment &&
            slotId == other.slotId &&
            roomId == other.roomId &&
            groupId == other.groupId;
  }

  @override
  int get hashCode => Object.hash(groupId, roomId, slotId);
}
