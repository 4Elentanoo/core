DROP PROCEDURE IF EXISTS enroll_student(int, int, date);

CREATE PROCEDURE enroll_student(p_student_id int, p_group_id int, p_on date DEFAULT current_date)
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active boolean;
    v_max       int;
BEGIN
    -- 1. группа существует
    SELECT is_active, max_students INTO v_is_active, v_max
    FROM training_group AS tg
    WHERE tg.id = p_group_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Группа с id % не найдена', p_group_id;
    END IF;

    -- 2. группа набирает учеников
    IF NOT v_is_active THEN
        RAISE EXCEPTION 'Данная группа не активна';
    END IF;

    -- 3. у ученика нет открытого членства в этой группе
    IF EXISTS (
        SELECT 1
        FROM student_group AS sg
        WHERE sg.student_id = p_student_id
          AND sg.training_group_id = p_group_id
          AND sg.end_date IS NULL
    ) THEN
        RAISE EXCEPTION 'Ученик уже состоит в этой группе';
    END IF;

    -- 4. на дату p_on есть свободное место
    IF (SELECT count(*) FROM group_members_on(p_group_id, p_on)) >= v_max THEN
        RAISE EXCEPTION 'Группа уже укомплектована, нет мест';
    END IF;

    -- 5. записываем: открытое членство с даты p_on
    INSERT INTO student_group (training_group_id, student_id, start_date)
    VALUES (p_group_id, p_student_id, p_on);
END;
$$;

COMMENT ON PROCEDURE enroll_student(int, int, date) IS
  'Записывает ученика p_student_id в группу p_group_id с даты p_on (по умолчанию сегодня). '
  'Отказ (RAISE EXCEPTION, изменения откатываются): группа не найдена; группа не активна; '
  'ученик уже состоит в группе (открытое членство); нет свободных мест на дату p_on (по group_members_on).';