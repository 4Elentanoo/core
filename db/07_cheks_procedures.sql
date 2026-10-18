-- checks_procedures.sql — тесты процедуры enroll_student.
-- Запускать после 00–05. Каждый блок — отдельной командой (Ctrl+Enter).
-- В CALL нельзя передавать подзапросы, поэтому id ищем в блоке DO по естественным ключам.
-- Тест 1 меняет данные: после всех тестов снова выполнить 00 → 05.


-- 3. Закрытая группа.
--    Ожидаем: ошибка «Данная группа не активна».
DO $$
DECLARE v_student int; v_group int;
BEGIN
    SELECT id INTO v_student FROM student WHERE last_name = 'Беляева' AND first_name = 'Алиса';
    SELECT id INTO v_group   FROM training_group WHERE name = 'Балет';
    CALL enroll_student(v_student, v_group);
END $$;

-- 4. Ученица уже в группе (открытое членство).
--    Ожидаем: ошибка «Ученик уже состоит в этой группе».
DO $$
DECLARE v_student int; v_group int;
BEGIN
    SELECT id INTO v_student FROM student WHERE last_name = 'Александрова' AND first_name = 'Елизавета';
    SELECT id INTO v_group   FROM training_group WHERE name = 'Грация';
    CALL enroll_student(v_student, v_group);
END $$;

-- 2. Группа заполнена: «Шпагат», 10 из 10.
--    Ожидаем: ошибка «Группа уже укомплектована, нет мест».
DO $$
DECLARE v_student int; v_group int;
BEGIN
    SELECT id INTO v_student FROM student WHERE last_name = 'Иванова' AND first_name = 'Ульяна';
    SELECT id INTO v_group   FROM training_group WHERE name = 'Шпагат';
    CALL enroll_student(v_student, v_group);
END $$;

-- 1. Успешная запись: Осипов ушёл из «Сальто» в мае (членство закрыто), в группе 11 из 12.
--    Ожидаем: без ошибок.
DO $$
DECLARE v_student int; v_group int;
BEGIN
    SELECT id INTO v_student FROM student WHERE last_name = 'Осипов' AND first_name = 'Егор';
    SELECT id INTO v_group   FROM training_group WHERE name = 'Сальто';
    CALL enroll_student(v_student, v_group, '2026-10-19');
END $$;

-- 1. Проверка: состав «Сальто» до и после даты записи.
--    Ожидаем: 18.10 — 11, 19.10 — 12 (день начала входит в период).
SELECT d, (SELECT count(*) FROM group_members_on((SELECT id FROM training_group WHERE name = 'Сальто'), d)) AS members
FROM (VALUES (date '2026-10-18'), (date '2026-10-19')) AS v(d);

-- 5. Повтор теста 1: верны обе причины отказа (уже состоит и 12 из 12).
--    Ожидаем: «Ученик уже состоит в этой группе» — проверки идут по порядку, срабатывает первая.
DO $$
DECLARE v_student int; v_group int;
BEGIN
    SELECT id INTO v_student FROM student WHERE last_name = 'Осипов' AND first_name = 'Егор';
    SELECT id INTO v_group   FROM training_group WHERE name = 'Сальто';
    CALL enroll_student(v_student, v_group, '2026-10-19');
END $$;