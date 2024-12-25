--- Запити прості ---
-- Список усіх дітей та їхніх батьків
select children.first_name  as child_name,
       children.second_name as child_surname,
       parents.first_name   as parent_name,
       parents.second_name  as parent_surname
from children
         join children_parents on children.child_id = children_parents.child_id
         join parents on children_parents.parent_id = parents.parent_id;

-- Усі заняття для груп із віковими межами від 1 до 2 років
select activities.activity_type,
       activities.activity_date,
       groups.group_name
from activities
         join groups on activities.group_id = groups.group_id
where groups.age_range = '1-2';

-- Усі батьки, чиї діти хворі
select parents.first_name   as parent_name,
       parents.second_name  as parent_surname,
       children.first_name  as child_name,
       children.second_name as child_surname,
       medical_records.health_status,
       medical_records.record_date
from parents
         join children_parents on parents.parent_id = children_parents.parent_id
         join children on children_parents.child_id = children.child_id
         join medical_records on children.child_id = medical_records.child_id
where medical_records.health_status = 'Sick';

-- Усі діти з групи "Happy Hippos"
select children.first_name  as child_name,
       children.second_name as child_surname,
       groups.group_name
from children
         join groups on children.group_id = groups.group_id
where groups.group_name = 'Happy Hippos';

-- Усі діти, які були на заняттях у вчителя з досвідом менше 5 років
select distinct children.first_name  as child_name,
                children.second_name as child_surname
from children
         join groups on children.group_id = groups.group_id
         join activities on groups.group_id = activities.group_id
         join teachers_groups on groups.group_id = teachers_groups.group_id
         join teachers on teachers_groups.teacher_id = teachers.teacher_id
where teachers.experience < 5;

-- Діти, які їли пасту на сніданок
select distinct children.first_name  as child_name,
                children.second_name as child_surname
from children
         join groups on children.group_id = groups.group_id
         join meals on groups.group_id = meals.group_id
where meals.meal_type = 'Breakfast'
  and meals.meal_name = 'Pasta';

-- Групи, вчителі яких заробляють більше 40000
select distinct groups.group_name
from groups
         join teachers_groups on groups.group_id = teachers_groups.group_id
         join teachers on teachers_groups.teacher_id = teachers.teacher_id
where teachers.salary > 40000;

-- Групи та загальна кількість дітей у них
select groups.group_name,
       count(children.child_id) as total_children
from groups
         join children on groups.group_id = children.group_id
group by groups.group_name
order by total_children;

-- Кількість дітей для кожного стану здоров'я
select medical_records.health_status,
       count(medical_records.child_id) as total_children
from medical_records
group by medical_records.health_status
order by total_children desc;

-- Викладачі і групи в яких вони працюють
select teachers.first_name  as teacher_name,
       teachers.second_name as teacher_surname,
       groups.group_name
from teachers
         join teachers_groups on teachers.teacher_id = teachers_groups.teacher_id
         join groups on teachers_groups.group_id = groups.group_id;

-- Діти та скільки вони пропустили
select children.first_name         as child_name,
       children.second_name        as child_surname,
       count(attendances.child_id) as total_absences
from children
         join attendances on children.child_id = attendances.child_id
where attendances.attendance_status = 'Absent'
group by children.child_id
order by total_absences desc;

-- Групи з найвищою середньою заробітною платою вчителя
select groups.group_name,
       avg(teachers.salary) as average_salary
from groups
         join teachers_groups on groups.group_id = teachers_groups.group_id
         join teachers on teachers_groups.teacher_id = teachers.teacher_id
group by groups.group_name
order by average_salary desc;

-- Найчастіше пропущений день тижня
select extract(dow from attendances.attendance_date) as day_of_week,
       count(attendances.attendance_id)              as total_absences
from attendances
where attendances.attendance_status = 'Absent'
group by day_of_week
order by total_absences desc
limit 1;

-- Вчителі та заняття, які вони проводили
select teachers.first_name  as teacher_name,
       teachers.second_name as teacher_surname,
       activities.activity_type,
       activities.activity_date
from teachers
         join teachers_groups on teachers.teacher_id = teachers_groups.teacher_id
         join activities on teachers_groups.group_id = activities.group_id;

-- Який тип занять проводиться найчастіше
select activities.activity_type,
       count(activities.activity_id) as total_activities
from activities
group by activities.activity_type
order by total_activities desc
limit 1;


--- З підзапитами ---
-- Усі заняття, які проводяться на вулиці для груп від 3 до 4 років
select activities.activity_type,
       activities.activity_date,
       activities.activity_time
from activities
where activities.group_id in (select groups.group_id
                              from groups
                              where groups.age_range = '3-4')
  and activities.activity_location = 'Outdoor';

-- Діти, які пропустили хоча б один день
select children.first_name  as child_name,
       children.second_name as child_surname
from children
where children.child_id in (select attendances.child_id
                            from attendances
                            where attendances.attendance_status = 'Absent');

-- Усі заняття, які проводили вчителі з досвідом більше 15 років
select activities.activity_type,
       activities.activity_date
from activities
where activities.group_id in (select teachers_groups.group_id
                              from teachers_groups
                                       join teachers on teachers_groups.teacher_id = teachers.teacher_id
                              where teachers.experience > 15);

-- Діти, які відвідали більше занять, між середня кількість занять
select children.first_name  as child_name,
       children.second_name as child_surname
from children
         join groups on children.group_id = groups.group_id
         join activities on groups.group_id = activities.group_id
group by children.child_id, children.first_name, children.second_name
having count(activities.activity_id) > (select avg(activity_count)
                                        from (select count(activity_id) as activity_count
                                              from activities
                                                       join groups on activities.group_id = groups.group_id
                                                       join children on groups.group_id = children.group_id
                                              group by children.child_id) as subquery);

-- Групи, в яких кількість дітей вища за середню
select groups.group_name,
       count(children.child_id) as total_children
from groups
         join children on groups.group_id = children.group_id
group by groups.group_name
having count(children.child_id) > (select avg(children_count)
                                   from (select count(child_id) as children_count
                                         from children
                                         group by group_id) as subquery);