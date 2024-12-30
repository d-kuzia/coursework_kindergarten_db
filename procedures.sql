--- Процедури ---
-- Cтворення процедури, в котрій робиться вибірка даних
-- Список дітей за вказаною групою
create or replace procedure children_by_group(g_name varchar(15))
    language plpgsql
as
$$
declare
    child_row record;
begin
    for child_row in select children.first_name, children.second_name
                     from children
                              join groups on children.group_id = groups.group_id
                     where groups.group_name = g_name
        loop
            raise notice 'Child: % %', child_row.first_name, child_row.second_name;
        end loop;
end;
$$;

call children_by_group('Sunshine Stars');

-- Створення процедури з використанням циклу FOR
-- Вираховує середній вік дітей в групі
create or replace procedure average_age_in_group(g_id int)
    language plpgsql
as
$$
declare
    avg_age numeric;
begin
    select avg(extract(year from age(date_of_birth)))
    into avg_age
    from children
    where group_id = g_id;

    raise notice 'Average age in group % is %', g_id, avg_age;
end;
$$;
call average_age_in_group(2);

-- Створення процедури з використанням умовної конструкції IF
-- Чи є у групи вказаний вчитель
create or replace procedure check_teacher_in_group(t_f_name varchar(15), g_name varchar(15))
    language plpgsql
as
$$
declare
    teacher_exists boolean;
begin
    select exists(select 1
                  from teachers
                           join teachers_groups on teachers.teacher_id = teachers_groups.teacher_id
                           join groups on teachers_groups.group_id = groups.group_id
                  where teachers.first_name = t_f_name
                    and groups.group_name = g_name)
    into teacher_exists;

    if teacher_exists then
        raise notice 'Teacher % is in group %', t_f_name, g_name;
    else
        raise notice 'Teacher % is not in group %', t_f_name, g_name;
    end if;
end;
$$;

call check_teacher_in_group('Sélène', 'Sunshine Stars');

-- Створення процедури, в якій використовується тимчасова таблиця, котра створена через змінну типу TABLE
-- Рахує кількість дітей в групах
create or replace procedure count_children_in_groups()
    language plpgsql
as
$$
declare
    rec record;
begin
    create temp table temp_table
    (
        group_name     varchar(15),
        children_count integer
    ) on commit drop;

    insert into temp_table
    select groups.group_name,
           count(children.child_id)
    from groups
             join children on groups.group_id = children.group_id
    group by groups.group_name;

    for rec in select * from temp_table
        loop
            raise notice 'Group: %, Children count: %', rec.group_name, rec.children_count;
        end loop;
end;
$$;

call count_children_in_groups();

-- Створення процедури оновлення даних в деякій таблиці БД;
-- Оновлення заробітної плати вчителя за його id на певний відсоток
create or replace procedure update_teacher_salary(t_id int, percent int)
    language plpgsql
as
$$
begin
    if not exists(select 1 from teachers where teacher_id = t_id) then
        raise notice 'Teacher with id % does not exist', t_id;
    end if;

    if percent <= 0 then
        raise notice 'Percent must be positive';
        return;
    end if;

    update teachers
    set salary = salary + salary * percent / 100
    where teacher_id = t_id;

    raise notice 'Teacher with id % salary updated by % percent', t_id, percent;
end;
$$;

call update_teacher_salary(5, 10);
