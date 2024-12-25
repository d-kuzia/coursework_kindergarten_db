create table teachers
(
    teacher_id  serial primary key,
    first_name  varchar(15) not null,
    second_name varchar(15) not null,
    experience  int check (experience >= 0),
    salary      int check (salary >= 0)
);

create table groups
(
    group_id   serial primary key,
    group_name varchar(15) not null unique,
    age_range  varchar(3)  not null check (age_range in ('1-2', '3-4', '5-6', '6-7'))
);

create table children
(
    child_id      serial primary key,
    first_name    varchar(15) not null,
    second_name   varchar(15) not null,
    date_of_birth date        not null check (date_of_birth < current_date),
    group_id      int         not null references groups (group_id)
);

create table activities
(
    activity_id       serial primary key,
    activity_type     varchar(5)  not null check (activity_type in ('Sport', 'Music', 'Art', 'Dance', 'Study')),
    activity_date     date        not null,
    activity_time     time        not null check (activity_time >= '08:00:00' and activity_time <= '16:00:00'),
    activity_location varchar(10) not null check (activity_location in ('Indoor', 'Outdoor')),
    group_id          int         not null references groups (group_id)
);

create table teachers_groups
(
    teacher_id int,
    group_id   int,
    primary key (teacher_id, group_id),
    foreign key (teacher_id) references teachers (teacher_id),
    foreign key (group_id) references groups (group_id)
);

create table parents
(
    parent_id    serial primary key,
    first_name   varchar(15)  not null,
    second_name  varchar(15)  not null,
    phone_number varchar(15)  not null unique,
    email        varchar(255) not null unique
);

alter table parents
    add constraint phone_number_format_check
        check ( phone_number ~ '^\+380[0-9]{9}$' );

ALTER TABLE parents
    ADD CONSTRAINT email_format_check
        CHECK (email ~ '^[a-zA-Z0-9._%+-]+@gmail\.com$');

create table children_parents
(
    child_id  int,
    parent_id int,
    primary key (child_id, parent_id),
    foreign key (child_id) references children (child_id),
    foreign key (parent_id) references parents (parent_id)
);

create table medical_records
(
    record_id     serial primary key,
    record_date   date        not null check (record_date <= current_date),
    health_status varchar(10) not null check (health_status in ('Healthy', 'Sick', 'Allergy')),
    child_id      int         not null references children (child_id)
);

create table attendances
(
    attendance_id     serial primary key,
    attendance_date   date        not null check (attendance_date <= current_date),
    attendance_status varchar(10) not null check (attendance_status in ('Present', 'Absent')),
    child_id          int         not null references children (child_id)
);

create table meals
(
    meal_id   serial primary key,
    meal_date date        not null check (meal_date <= current_date),
    meal_type varchar(10) not null check (meal_type in ('Breakfast', 'Lunch', 'Dinner')),
    group_id  int         not null references groups (group_id),
    unique (meal_date, meal_type, group_id)
);

alter table meals
    add column meal varchar(50);

alter table meals
    rename column meal to meal_name;

alter table meals
    alter column meal set not null;

alter table meals
    alter column meal_name type varchar(25);
