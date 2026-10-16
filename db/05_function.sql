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

