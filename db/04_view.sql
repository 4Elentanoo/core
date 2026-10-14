-- 1
CREATE OR REPLACE VIEW v_week_schedule AS
select s.day_of_week                               as day_of_week,
       s.start_time                                as start_time,
       tg.name                                     as group_name,
       ts.name                                     as sport,
       concat_ws(' ', ac.first_name, ac.last_name) as trainer,
       r.name                                      as room
from assignment as a
join slot as s                on s.id = a.slot_id
join room as r                on r.id = a.room_id
join group_trainer as gt      on gt.id = a.group_trainer_id
join training_group as tg     on tg.id = gt.training_group_id
join type_sport as ts         on ts.id = tg.type_sport_id
join trainer_for_sport as tfs on tfs.id = gt.trainer_for_sport_id
join trainer as t             on t.id = tfs.trainer_id
join account as ac            on ac.id = t.account_id
order by s.day_of_week, s.start_time, r.name, r.id;

COMMENT ON VIEW v_week_schedule IS 'Расписание недели: группа, тренер, зал, пара';

-- 2
create or replace view v_group_fill as
select tg.name                                as group_name,
       tg.is_active                           as is_active,
       tg.max_students                        as max_students,
       count(sg.student_id)                   as enrolled,
       tg.max_students - count(sg.student_id) as free_places
from training_group as tg
left join student_group as sg
       on sg.training_group_id = tg.id
      and sg.end_date is null
group by tg.id
order by free_places, group_name;

COMMENT ON VIEW v_group_fill IS 'Заполненность групп: записано сейчас (открытые членства) и свободные места. Включает закрытые группы';

