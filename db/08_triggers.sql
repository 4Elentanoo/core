-- тренер не ведёт два занятия в одну пару

DROP TRIGGER IF EXISTS trg_assignment_trainer_busy ON assignment;
DROP FUNCTION IF EXISTS assignment_trainer_busy_check();

CREATE FUNCTION assignment_trainer_busy_check()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_trainer_id int;
BEGIN
    -- 1. тренер новой записи: NEW.group_trainer_id → group_trainer → trainer_for_sport.trainer_id
    SELECT tfs.trainer_id INTO v_trainer_id
    FROM group_trainer AS gt
    JOIN trainer_for_sport AS tfs ON gt.trainer_for_sport_id = tfs.id
    WHERE gt.id = NEW.group_trainer_id;

    -- 2. другая запись расписания в ту же пару с тем же тренером
    --    (сравниваем trainer_id: у тренера может быть несколько записей trainer_for_sport)
    IF EXISTS (
        SELECT 1
        FROM assignment AS a
        JOIN group_trainer AS gt      ON gt.id  = a.group_trainer_id
        JOIN trainer_for_sport AS tfs ON tfs.id = gt.trainer_for_sport_id
        WHERE a.slot_id      = NEW.slot_id
          AND tfs.trainer_id = v_trainer_id
          AND a.id          <> NEW.id          -- при UPDATE не считаем саму изменяемую запись
    ) THEN
        RAISE EXCEPTION 'Тренер уже ведёт занятие в эту пару';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_assignment_trainer_busy
BEFORE INSERT OR UPDATE ON assignment
FOR EACH ROW
EXECUTE FUNCTION assignment_trainer_busy_check();

COMMENT ON FUNCTION assignment_trainer_busy_check() IS
  'Триггерная функция Ж1: отклоняет запись расписания, если тренер этой группы уже ведёт другую группу в ту же пару. '
  'Тренер определяется через group_trainer → trainer_for_sport.trainer_id.';
COMMENT ON TRIGGER trg_assignment_trainer_busy ON assignment IS
  'Ж1: тренер не может вести два занятия в одну пару (BEFORE INSERT OR UPDATE)';