-- тесты триггера trg_assignment_trainer_busy (Ж1).
-- Запускать после 00–06. Каждую команду — отдельно (Ctrl+Enter).
-- Тесты 2 и 4 меняют данные: после всех тестов снова выполнить 00 → 06.
-- Петров ведёт «Пирамиду» (акробатика) и «Силу» (ОФП) — это две разные записи trainer_for_sport.


-- 1. «Сила» (Петров) в пн 18:30 — в эту пару Петров уже ведёт «Пирамиду» в акробатическом зале.
--    Зал «Большой ковровый» в эту пару свободен, так что мешать может только тренер.
--    Ожидаем: ошибка триггера «Тренер уже ведёт занятие в эту пару».
INSERT INTO assignment (group_trainer_id, room_id, slot_id) VALUES (
  (SELECT gt.id FROM group_trainer gt JOIN training_group tg ON tg.id = gt.training_group_id
   WHERE tg.name = 'Сила' AND gt.end_date IS NULL),
  (SELECT id FROM room WHERE name = 'Большой ковровый'),
  (SELECT id FROM slot WHERE day_of_week = 1 AND start_time = '18:30'));

-- 2. «Сила» в ср 17:00, акробатический зал: Петров свободен, зал свободен.
--    Ожидаем: вставка проходит.
INSERT INTO assignment (group_trainer_id, room_id, slot_id) VALUES (
  (SELECT gt.id FROM group_trainer gt JOIN training_group tg ON tg.id = gt.training_group_id
   WHERE tg.name = 'Сила' AND gt.end_date IS NULL),
  (SELECT id FROM room WHERE name = 'Акробатический'),
  (SELECT id FROM slot WHERE day_of_week = 3 AND start_time = '17:00'));

-- 3. Перенос занятия «Силы» с пн 20:00 на пн 18:30 (в Большой ковровый).
--    Ожидаем: ошибка триггера — в пн 18:30 Петров занят «Пирамидой».
UPDATE assignment
SET slot_id = (SELECT id FROM slot WHERE day_of_week = 1 AND start_time = '18:30'),
    room_id = (SELECT id FROM room WHERE name = 'Большой ковровый')
WHERE group_trainer_id = (SELECT gt.id FROM group_trainer gt JOIN training_group tg ON tg.id = gt.training_group_id
                          WHERE tg.name = 'Сила' AND gt.end_date IS NULL)
  AND slot_id = (SELECT id FROM slot WHERE day_of_week = 1 AND start_time = '20:00');

-- 4. То же занятие «Силы» пн 20:00 — меняем только зал на «Малый».
--    Ожидаем: обновление проходит (запись не конфликтует сама с собой: a.id <> NEW.id).
UPDATE assignment
SET room_id = (SELECT id FROM room WHERE name = 'Малый')
WHERE group_trainer_id = (SELECT gt.id FROM group_trainer gt JOIN training_group tg ON tg.id = gt.training_group_id
                          WHERE tg.name = 'Сила' AND gt.end_date IS NULL)
  AND slot_id = (SELECT id FROM slot WHERE day_of_week = 1 AND start_time = '20:00');

-- 5. «Атлет» (Морозов) в пн 18:30 в акробатический зал: Морозов свободен, но зал занят «Пирамидой».
--    Ожидаем: ошибка ограничения assignment_room_id_slot_id_key (UNIQUE), а не триггера —
--    триггер проверяет только тренера и пропускает строку дальше.
INSERT INTO assignment (group_trainer_id, room_id, slot_id) VALUES (
  (SELECT gt.id FROM group_trainer gt JOIN training_group tg ON tg.id = gt.training_group_id
   WHERE tg.name = 'Атлет' AND gt.end_date IS NULL),
  (SELECT id FROM room WHERE name = 'Акробатический'),
  (SELECT id FROM slot WHERE day_of_week = 1 AND start_time = '18:30'));