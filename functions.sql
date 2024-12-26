--- Функції ---
-- повертає деяке скалярне значення;
-- Кількість дітей, які відсутні в якийсь день
create or replace function get_absent_children_count(a_date date)
    returns int
    language plpgsql
as
$$
declare
    absent_children_count int;
begin
    select count(*)
    into absent_children_count
    from attendances
    where attendance_status = 'Absent'
      and attendance_date = a_date;

    return absent_children_count;
end;
$$;

select get_absent_children_count('2024-12-19');

-- повертає таблицю з динамічним набором стовпців;
-- Повертає динамічні дані з таблиці activities за id групи
create or replace function get_activities_data_dynamic(cols text, g_id int)
    returns table
            (
                dynamic_result json
            )
    language plpgsql
as
$$
begin
    return query
        execute format(
            'select json_agg(row_to_json(t))' ||
            'from (select %s from activities where group_id = %L) t;',
            cols, g_id
                );
end;
$$;

select *
from get_activities_data_dynamic('activity_location', 1);


-- повертає таблицю наперед заданої структури
-- Заняття з датою, проведені вчителем за заданим id вчителя
create or replace function get_activities_by_teacher(t_id int)
    returns table
            (
                activity_type varchar(5),
                activity_date date
            )
    language plpgsql
as
$$
begin
    return query
        select activities.activity_type, activities.activity_date
        from activities
        where public.activities.group_id in (select teachers_groups.group_id
                                             from teachers_groups
                                             where teacher_id = t_id);
end;
$$;

select *
from get_activities_by_teacher(5);

-- Meals які подавались в зазначений день в зазначеній групі
create or replace function get_meals_by_date_and_group(m_date date, g_id int)
    returns table
            (
                meal_type varchar(10),
                meal_name varchar(25)
            )
    language plpgsql
as
$$
begin
    return query
        select meals.meal_type, meals.meal_name
        from meals
        where meals.group_id = g_id
          and meals.meal_date = m_date;
end;
$$;

select *
from get_meals_by_date_and_group('2024-12-19', 3);

-- Всі дати відвідувань для заданої дитини
create or replace function attendance_dates_for_child(c_id int)
    returns table
            (
                attendance_date   date,
                attendance_status varchar(10)
            )
    language plpgsql
as
$$
begin
    return query
        select attendances.attendance_date, attendances.attendance_status
        from attendances
        where attendances.child_id = c_id;
end;
$$;

select *
from attendance_dates_for_child(1);
