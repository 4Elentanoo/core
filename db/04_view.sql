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

