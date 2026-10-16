create or replace function current_category(p_trainer_id int, p_on date default current_date)
returns varchar
language sql
stable
as $$
    select c.name
    from trainer_category as tc
    join category as c on c.id = tc.category_id
    where tc.trainer_id = p_trainer_id
      and tc.assigned_at <= p_on
    order by tc.assigned_at desc, tc.id desc
    limit 1;
$$;

COMMENT ON FUNCTION current_category(int, date) IS
  'Категория тренера на дату p_on (по умолчанию сегодня): последнее присвоение не позже этой даты. NULL, если на эту дату категорий ещё не было';

select current_category(
         (select t.id
          from trainer as t
          join account as a on a.id = t.account_id
          where a.last_name = 'Белова'),
         '2022-10-01'
       ) as category_name;


DROP FUNCTION IF EXISTS current_category(int, date);

CREATE FUNCTION current_category(p_trainer_id int, p_on date DEFAULT current_date)
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT c.name
    FROM trainer_category AS tc
    JOIN category AS c ON c.id = tc.category_id
    WHERE tc.trainer_id = p_trainer_id
      AND tc.assigned_at <= p_on
    ORDER BY tc.assigned_at DESC, tc.id DESC
    LIMIT 1;
$$;

COMMENT ON FUNCTION current_category(int, date) IS
  'Категория тренера на дату p_on (по умолчанию сегодня): последнее присвоение не позже этой даты. '
  'NULL, если на эту дату категорий ещё не было.';


DROP FUNCTION IF EXISTS group_members_on(int, date);

CREATE FUNCTION group_members_on(p_group_id int, p_on date)
RETURNS TABLE (student_id int, student text)
LANGUAGE sql
STABLE
AS $$
    SELECT s.id                                      AS student_id,
           concat_ws(' ', s.last_name, s.first_name) AS student
    FROM student AS s
    JOIN student_group AS sg ON sg.student_id = s.id
    WHERE sg.training_group_id = p_group_id
      AND sg.start_date <= p_on
      AND (sg.end_date IS NULL OR sg.end_date > p_on)
    ORDER BY student, s.id;
$$;

COMMENT ON FUNCTION group_members_on(int, date) IS
  'Состав группы p_group_id на дату p_on: id и «Фамилия Имя» учеников. '
  'Ученик в группе, если start_date <= p_on и (end_date пусто или end_date > p_on): '
  'день прихода входит, день ухода не входит.';


DROP FUNCTION IF EXISTS room_fits_group(int, int);

CREATE FUNCTION room_fits_group(p_room_id int, p_group_id int)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT r.capacity >= tg.max_students
           AND NOT EXISTS (                      -- нет такого требуемого оборудования...
                 SELECT 1
                 FROM section_equipment AS se
                 WHERE se.type_sport_id = tg.type_sport_id
                   AND NOT EXISTS (              -- которого не было бы в зале сейчас
                         SELECT 1
                         FROM equipment_placement AS ep
                         JOIN item AS i ON i.id = ep.item_id
                         WHERE ep.room_id = p_room_id
                           AND ep.date_end IS NULL
                           AND i.equipment_id = se.equipment_id
                       )
               )
    FROM training_group AS tg
    JOIN room AS r ON r.id = p_room_id
    WHERE tg.id = p_group_id;
$$;

COMMENT ON FUNCTION room_fits_group(int, int) IS
  'true, если зал p_room_id подходит группе p_group_id: вместимость не меньше max_students '
  'и в зале сейчас (date_end IS NULL) есть всё оборудование, нужное виду спорта группы. '
  'NULL, если зала или группы нет.';