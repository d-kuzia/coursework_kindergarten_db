--- Тригери ---
-- Дитина не може бути присутня маючи хворобу або алергію
create or replace function enforce_medical_status_rules()
    returns trigger
    language plpgsql
as
$$
begin
    if (new.attendance_status = 'Present') then
        if exists (select 1
                   from medical_records
                   where child_id = new.child_id
                     and health_status in ('Sick', 'Allergy')) then
            raise exception 'Child cannot be present with health status Sick or Allergy';
        end if;
    end if;
    return new;
end;
$$;

create trigger enforce_medical_status_rules
    before insert or update
    on attendances
    for each row
execute function enforce_medical_status_rules();

insert into attendances (child_id, attendance_date, attendance_status)
values (241, '2024-12-18', 'Present');

-- Дитина не може потрапити в групу не своєї вікової категорії
create or replace function enforce_age_range_rules()
    returns trigger
    language plpgsql
as
$$
declare
    group_age_range varchar(3);
    child_age       int;
begin
    select age_range
    into group_age_range
    from groups
    where group_id = new.group_id;

    select extract(year from age(children.date_of_birth))
    into child_age
    from children
    where children.child_id = new.child_id;

    if (group_age_range = '1-2' and not (child_age between 1 and 2)) or
       (group_age_range = '3-4' and not (child_age between 3 and 4)) or
       (group_age_range = '5-6' and not (child_age between 5 and 6)) or
       (group_age_range = '7-8' and not (child_age between 7 and 8)) then
        raise exception 'Child age % does not match the age range % of the group', child_age, group_age_range;
    end if;

    return new;
end;
$$;

create trigger enforce_age_range_rules
    before insert or update
    on children
    for each row
execute function enforce_age_range_rules();

insert into children (first_name, second_name, date_of_birth, group_id)
values ('John', 'Doe', '2019-12-18', 1);

-- Дитина не може бути в декількох групах одночасно
create or replace function enforce_single_group_per_child()
    returns trigger
    language plpgsql
as
$$
begin
    if exists (select 1
               from children
               where child_id = new.child_id
                 and group_id != new.group_id) then
        raise exception 'Child cannot be in multiple groups';
    end if;
    return new;
end;
$$;

create trigger enforce_single_group_per_child
    before insert or update
    on children
    for each row
execute function enforce_single_group_per_child();

insert into children (child_id, first_name, second_name, date_of_birth, group_id)
values (202, 'Jessica', 'Good', '2018-12-24', 9);

-- Вчитель не може мати зарплату більше ніж 50000
create or replace function enforce_salary_limit()
    returns trigger
    language plpgsql
as
$$
begin
    if (new.salary > 50000) then
        raise exception 'Salary cannot exceed 50000';
    end if;
    return new;
end;
$$;

create trigger enforce_salary_limit
    before insert or update
    on teachers
    for each row
execute function enforce_salary_limit();

insert into teachers (first_name, second_name, experience, salary)
values ('John', 'Doe', 15, '51000');

-- Група не може мати два однакові типи прийому їжі в один день
create or replace function enforce_unique_meal_types_per_day()
    returns trigger
    language plpgsql
as
$$
begin
    if exists (select 1
               from meals
               where group_id = new.group_id
                 and meal_date = new.meal_date
                 and meal_type = new.meal_type) then
        raise exception 'Group cannot have two %s on the same day', new.meal_type;
    end if;
    return new;
end;
$$;

create trigger enforce_unique_meal_types_per_day
    before insert or update
    on meals
    for each row
execute function enforce_unique_meal_types_per_day();

insert into meals (meal_type, meal_name, meal_date, group_id)
values ('Breakfast', 'Cereal', '2024-12-18', 1);

-- Назва групи не може співпадати з назвою іншої групи
create or replace function enforce_unique_group_names()
    returns trigger
    language plpgsql
as
$$
begin
    if exists (select 1
               from groups
               where group_name = new.group_name) then
        raise exception 'Group with name % already exists', new.group_name;
    end if;
    return new;
end;
$$;

create trigger enforce_unique_group_names
    before insert or update
    on groups
    for each row
execute function enforce_unique_group_names();

insert into groups (group_name, age_range)
values ('Sunshine Stars', '3-4');

