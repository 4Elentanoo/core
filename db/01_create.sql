CREATE TABLE  account (
  id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name    varchar NOT NULL,
  last_name     varchar NOT NULL,
  mail          varchar NOT NULL,
  phone         varchar NOT NULL UNIQUE,
  password_hash varchar NOT NULL
);
CREATE UNIQUE INDEX  account_mail_lower_uq ON account (lower(mail));

CREATE TABLE  role (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar NOT NULL UNIQUE
);

CREATE TABLE  account_role (
  account_id integer NOT NULL REFERENCES account (id),
  role_id    integer NOT NULL REFERENCES role (id),
  PRIMARY KEY (account_id, role_id)
);

CREATE TABLE  trainer (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_id integer NOT NULL UNIQUE REFERENCES account (id)
);

CREATE TABLE  category (
  id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name  varchar NOT NULL,
  level integer NOT NULL UNIQUE CHECK (level > 0)
);

CREATE TABLE  trainer_category (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  trainer_id  integer NOT NULL REFERENCES trainer (id),
  category_id integer NOT NULL REFERENCES category (id),
  assigned_at date    NOT NULL
);

CREATE TABLE  type_sport (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        varchar NOT NULL,
  description varchar
);

CREATE TABLE  trainer_for_sport (
  id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type_sport_id   integer NOT NULL REFERENCES type_sport (id),
  trainer_id      integer NOT NULL REFERENCES trainer (id),
  date_assignment date    NOT NULL
);

CREATE TABLE  stage (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name             varchar NOT NULL,
  lessons_per_week integer NOT NULL CHECK (lessons_per_week > 0)
);

CREATE TABLE  training_group (
  id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name            varchar NOT NULL,
  type_sport_id   integer NOT NULL REFERENCES type_sport (id),
  stage_id        integer NOT NULL REFERENCES stage (id),
  max_students    integer NOT NULL CHECK (max_students > 0),
  is_active       boolean NOT NULL DEFAULT TRUE,
  min_category_id integer NOT NULL REFERENCES category (id)
);

CREATE TABLE  group_trainer (
  id                   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  training_group_id    integer NOT NULL REFERENCES training_group (id),
  trainer_for_sport_id integer NOT NULL REFERENCES trainer_for_sport (id),
  start_date           date    NOT NULL,
  end_date             date,
  CONSTRAINT group_trainer_period_chk CHECK (end_date > start_date)
);

CREATE TABLE  student (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name varchar  NOT NULL,
  last_name  varchar  NOT NULL,
  parent_id  integer  NOT NULL REFERENCES account (id),
  birth_year smallint NOT NULL
);

CREATE TABLE  student_group (
  id                integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  training_group_id integer NOT NULL REFERENCES training_group (id),
  student_id        integer NOT NULL REFERENCES student (id),
  start_date        date    NOT NULL,
  end_date          date,
  CONSTRAINT student_group_period_chk CHECK (end_date > start_date)
);

CREATE UNIQUE INDEX  student_group_open_member_uq ON student_group (student_id, training_group_id)
WHERE end_date IS NULL;

CREATE TABLE  room (
  id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name     varchar NOT NULL,
  number   integer,
  capacity integer NOT NULL CHECK (capacity > 0)
);

CREATE TABLE  slot (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  start_time  time     NOT NULL,
  day_of_week smallint NOT NULL CHECK (day_of_week BETWEEN 1 AND 6), -- CHECK (day_of_week >= 1 AND day_of_week <= 6)
  UNIQUE (day_of_week, start_time)
);

CREATE TABLE  trainer_availability (
  trainer_id integer NOT NULL REFERENCES trainer (id),
  slot_id    integer NOT NULL REFERENCES slot (id),
  PRIMARY KEY (trainer_id, slot_id)
);

CREATE TABLE  assignment (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  group_trainer_id integer NOT NULL REFERENCES group_trainer (id),
  room_id          integer NOT NULL REFERENCES room (id),
  slot_id          integer NOT NULL REFERENCES slot (id),
  UNIQUE (room_id, slot_id),
  UNIQUE (group_trainer_id, slot_id)
);

CREATE TABLE  equipment (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar NOT NULL
);

CREATE TABLE  item (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name             varchar,
  description      varchar,
  equipment_id     integer NOT NULL REFERENCES equipment (id),
  inventory_number varchar NOT NULL UNIQUE
);

CREATE TABLE  equipment_placement (
  id           integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  item_id      integer NOT NULL REFERENCES item (id),
  room_id      integer NOT NULL REFERENCES room (id),
  date_install date    NOT NULL,
  date_end     date,
  CONSTRAINT equipment_placement_period_chk CHECK (date_end > date_install)
);

CREATE UNIQUE INDEX  equipment_placement_open_item_uq ON equipment_placement (item_id)
WHERE date_end IS NULL;

CREATE TABLE  section_equipment (
  type_sport_id integer NOT NULL REFERENCES type_sport (id),
  equipment_id  integer NOT NULL REFERENCES equipment (id),
  PRIMARY KEY (type_sport_id, equipment_id)
);

CREATE TABLE  lesson_status (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar NOT NULL UNIQUE
);

CREATE TABLE  lesson (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  assignment_id    integer NOT NULL REFERENCES assignment (id),
  lesson_status_id integer NOT NULL REFERENCES lesson_status (id),
  lesson_date      date    NOT NULL,
  comment          varchar,
  slot_id          integer NOT NULL REFERENCES slot (id),
  room_id          integer NOT NULL REFERENCES room (id)
);

CREATE TABLE  attendance_status (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar NOT NULL UNIQUE
);

CREATE TABLE  attendance (
  lesson_id            integer NOT NULL REFERENCES lesson (id),
  student_id           integer NOT NULL REFERENCES student (id),
  attendance_status_id integer NOT NULL REFERENCES attendance_status (id),
  PRIMARY KEY (lesson_id, student_id)
);