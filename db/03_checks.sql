-- ============ slot

-- 1. Повтор пары: понедельник, 9:30 уже есть в сетке из сида.
--    Ожидаем: ошибка, slot_day_of_week_start_time_key (UNIQUE (day_of_week, start_time)).
INSERT INTO slot (day_of_week, start_time) VALUES (1, '09:30');

-- 2. День недели вне сетки пн–сб.
--    Ожидаем: ошибка, slot_day_of_week_check (CHECK day_of_week BETWEEN 1 AND 6).
INSERT INTO slot (day_of_week, start_time) VALUES (7, '09:30');


-- ============ group_trainer: период полуоткрытый, конец не входит (решение 19)
-- Группа «Гармония» и любая запись тренера того же вида спорта — подзапросами, без id руками.

-- 3. Обычный период: 1 сентября — 15 января.
--    Ожидаем: вставка проходит.
INSERT INTO group_trainer (training_group_id, trainer_for_sport_id, start_date, end_date)
VALUES (
  (SELECT id FROM training_group WHERE name = 'Гармония'),
  (SELECT tfs.id
   FROM trainer_for_sport tfs
   JOIN training_group tg ON tfs.type_sport_id = tg.type_sport_id
   WHERE tg.name = 'Гармония'
   ORDER BY tfs.id
   LIMIT 1),
  '2026-09-01', '2027-01-15'
);

-- 4. Конец раньше начала.
--    Ожидаем: ошибка, group_trainer_period_chk.
INSERT INTO group_trainer (training_group_id, trainer_for_sport_id, start_date, end_date)
VALUES (
  (SELECT id FROM training_group WHERE name = 'Гармония'),
  (SELECT tfs.id
   FROM trainer_for_sport tfs
   JOIN training_group tg ON tfs.type_sport_id = tg.type_sport_id
   WHERE tg.name = 'Гармония'
   ORDER BY tfs.id
   LIMIT 1),
  '2026-09-01', '2026-08-01'
);

-- 5. Период длиной ноль дней: начало и конец в один день. Условие строгое: end_date > start_date.
--    Ожидаем: ошибка, group_trainer_period_chk.
INSERT INTO group_trainer (training_group_id, trainer_for_sport_id, start_date, end_date)
VALUES (
  (SELECT id FROM training_group WHERE name = 'Гармония'),
  (SELECT tfs.id
   FROM trainer_for_sport tfs
   JOIN training_group tg ON tfs.type_sport_id = tg.type_sport_id
   WHERE tg.name = 'Гармония'
   ORDER BY tfs.id
   LIMIT 1),
  '2026-09-01', '2026-09-01'
);

-- 6. Открытый период: конец не задан.
--    Сравнение с NULL даёт «неизвестно», а CHECK отклоняет строку только при «ложно».
--    Ожидаем: вставка проходит.
INSERT INTO group_trainer (training_group_id, trainer_for_sport_id, start_date, end_date)
VALUES (
  (SELECT id FROM training_group WHERE name = 'Гармония'),
  (SELECT tfs.id
   FROM trainer_for_sport tfs
   JOIN training_group tg ON tfs.type_sport_id = tg.type_sport_id
   WHERE tg.name = 'Гармония'
   ORDER BY tfs.id
   LIMIT 1),
  '2026-09-01', NULL
);


-- ============ account: почта уникальна без учёта регистра

-- 7. Предусловие: такая почта уже есть (в нижнем регистре).
--    Ожидаем: одна строка.
SELECT mail FROM account WHERE lower(mail) = lower('SVETLANA.ZAKHAROVA@zhemchuzhina.ru');

-- 7. Та же почта заглавными буквами, остальные поля новые.
--    Ожидаем: ошибка, account_mail_lower_uq (уникальный индекс по lower(mail)).
INSERT INTO account (first_name, last_name, mail, phone, password_hash)
VALUES ('Светлана', 'Захарова', 'SVETLANA.ZAKHAROVA@zhemchuzhina.ru', '+7 986 421-36-11',
        '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6');