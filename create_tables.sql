create table teachers (
    teacher_id serial primary key,
    first_name varchar(15) not null,
    second_name varchar(15) not null,
    experience int,
    salary int
);

create table groups (
    group_id serial primary key,
    group_name varchar(15) not null,
    age_range varchar(10) not null
);

create table children (
    child_id serial primary key,
    first_name varchar(15) not null,
    second_name varchar(15) not null,
    date_of_birth date not null,
    group_id int,
    foreign key (group_id) references groups(group_id)
);

create table activities (
    activity_id serial primary key,
    activity_name varchar(15) not null,
    activity_type varchar(15) not null,
    activity_date date not null,
    activity_time time not null,
    activity_duration int not null,
    activity_location varchar(50) not null,
    group_id int,
    foreign key (group_id) references groups(group_id)
);

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

create table attendances (
    attendance_id serial primary key,
    attendance_date date not null,
    attendance_time time not null,
    attendance_status varchar(10) not null,
    child_id int,
    foreign key (child_id) references children(child_id)
);