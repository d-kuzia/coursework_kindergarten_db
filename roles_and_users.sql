--- Ролі ---
create role admin;
create role teacher;
create role parent;
create role manager;
create role medical_staff;

--- Користувачі ---
create user admin_u with password 'admin';
create user teacher_u with password 'teacher';
create user parent_u with password 'parent';
create user manager_u with password 'manager';
create user medical_u with password 'medical';

--- Надання привілеїв ---
-- Адміністратор
grant all privileges on all tables in schema public to admin;
grant all privileges on all sequences in schema public to admin;
grant all privileges on all functions in schema public to admin;

-- Вчитель (Вихователь)
grant select on children, groups, activities, teachers, medical_records to teacher;
grant select, insert, update on attendances to teacher_role;

-- Батьки
grant select on children, medical_records, meals, activities, attendances, groups to parent;

-- Менеджер
grant select on groups, teachers, children, parents to manager;
grant select, insert, update on meals, children_parents, teachers_groups to manager;

-- Медичний персонал
grant select on children to medical_staff;
grant select, insert, update on medical_records to medical_staff;

--- Надання ролей користувачам ---
grant admin to admin_u;
grant teacher to teacher_u;
grant parent to parent_u;
grant manager to manager_u;
grant medical_staff to medical_u;


