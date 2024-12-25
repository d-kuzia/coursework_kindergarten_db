--- Представлення ---
-- Діти та їх вік
create view children_with_age as
select children.child_id,
       children.first_name,
       children.second_name,
       children.date_of_birth,
       extract(year from age(children.date_of_birth)) as age
from children;

select *
from children_with_age;

-- Діти та назва їх групи
create view children_with_group as
select children.child_id,
       children.first_name,
       children.second_name,
       groups.group_name
from children
         join groups on children.group_id = groups.group_id;

select *
from children_with_group;

-- Діти та їх батьки
create view children_with_parents as
select children.child_id,
       children.first_name,
       children.second_name,
       parents.first_name  as parent_name,
       parents.second_name as parent_surname
from children
         join children_parents on children.child_id = children_parents.child_id
         join parents on children_parents.parent_id = parents.parent_id;

select *
from children_with_parents;

-- Вчителі та їх зарплата, досвід, група та кількість дітей в ній
create view teachers_salaries_experience_group_children_count as
select teachers.teacher_id,
       teachers.first_name      as teacher_name,
       teachers.second_name     as teacher_surname,
       teachers.salary,
       teachers.experience,
       groups.group_name,
       count(children.child_id) as children_count
from teachers
         join teachers_groups on teachers.teacher_id = teachers_groups.teacher_id
         join groups on teachers_groups.group_id = groups.group_id
         join children on groups.group_id = children.group_id
group by teachers.teacher_id, teachers.first_name, teachers.second_name, teachers.salary, teachers.experience,
         groups.group_name;

select *
from teachers_salaries_experience_group_children_count;
