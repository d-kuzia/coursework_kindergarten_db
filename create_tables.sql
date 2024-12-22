create table teachers (
    teacher_id serial primary key,
    first_name varchar(15) not null,
    second_name varchar(15) not null,
    experience int,
    salary int
);

alter table teachers
    add constraint chk_experience check (experience >= 0),
    add constraint chk_salary check (salary >= 0);

create table groups (
    group_id serial primary key,
    group_name varchar(15) not null,
    age_range varchar(10) not null
);

alter table groups
    add constraint chk_age_range check (age_range in ('1-2', '3-4', '5-6', '6-7'));
alter table groups
    add constraint unique_group_name UNIQUE (group_name);
alter table groups
    alter column age_range type varchar(3);


create table children (
    child_id serial primary key,
    first_name varchar(15) not null,
    second_name varchar(15) not null,
    date_of_birth date not null,
    group_id int,
    foreign key (group_id) references groups(group_id)
);

alter table children
    add constraint chk_date_of_birth check (date_of_birth < current_date);
alter table children
    alter column group_id set not null;

create table activities (
    activity_id serial primary key,
    activity_name varchar(15) not null,
    activity_type varchar(15) not null,
    activity_date date not null,
    activity_time time not null,
    activity_location varchar(50) not null,
    group_id int,
    foreign key (group_id) references groups(group_id)
);
alter table activities
    add column activity_duration interval default '0 hours';

alter table activities
    alter column activity_duration set not null;

alter table activities
    add constraint chk_duration check (activity_duration > 0);
alter table activities
    add constraint chk_activity_date check (activity_date >= current_date),
    add constraint chk_activity_time check (activity_time >= '08:00:00' and activity_time <= '20:00:00'),
    add constraint chk_activity_type check (activity_type in ('Sport', 'Music', 'Art', 'Dance')),
    add constraint chk_activity_location check (activity_location in ('Indoor', 'Outdoor'));
alter table activities
    alter column group_id set not null;
alter table activities
    alter column activity_type type varchar(5),
    alter column activity_location type varchar(10);

create table teachers_groups (
    teacher_id int,
    group_id int,
    primary key (teacher_id, group_id),
    foreign key (teacher_id) references teachers(teacher_id),
    foreign key (group_id) references groups(group_id)
);

create table teachers_activities (
    teacher_id int,
    activity_id int,
    primary key (teacher_id, activity_id),
    foreign key (teacher_id) references teachers(teacher_id),
    foreign key (activity_id) references activities(activity_id)
);

create table parents (
    parent_id serial primary key,
    first_name varchar(15) not null,
    second_name varchar(15) not null,
    phone_number varchar(15) not null unique,
    email varchar(25) not null unique
);

alter table parents
    add constraint chk_phone_number check (phone_number ~ '^\+380\d{9}$'),
    add constraint chk_email check (email ~ '^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

alter table parents
    alter column email type varchar(255);

create table children_parents (
    child_id int,
    parent_id int,
    primary key (child_id, parent_id),
    foreign key (child_id) references children(child_id),
    foreign key (parent_id) references parents(parent_id)
);

create table medical_records (
    record_id serial primary key,
    record_date date not null,
    record_description text not null,
    child_id int,
    foreign key (child_id) references children(child_id)
);

alter table medical_records
    add constraint chk_record_date check (record_date <= current_date);
alter table medical_records
    alter column child_id set not null;

create table attendances (
    attendance_id serial primary key,
    attendance_date date not null,
    attendance_status varchar(10) not null,
    child_id int,
    foreign key (child_id) references children(child_id)
);

alter table attendances
    add constraint chk_attendance_status check (attendance_status in ('Present', 'Absent', 'Sick'));
alter table attendances
    add constraint chk_attendance_date check (attendance_date <= current_date);
alter table attendances
    alter column child_id set not null;