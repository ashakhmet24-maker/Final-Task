SELECT current_database();

CREATE SCHEMA IF NOT EXISTS fitness_club;

CREATE TABLE IF NOT EXISTS fitness_club.locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS fitness_club.membership_plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50) UNIQUE NOT NULL,
    monthly_price NUMERIC(10,2) NOT NULL CHECK (monthly_price >= 0)
);

CREATE TABLE IF NOT EXISTS fitness_club.members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    gender VARCHAR(10) NOT NULL
        CHECK (gender IN ('Male','Female','Other'))
);

CREATE TABLE IF NOT EXISTS fitness_club.trainers (
    trainer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    full_name VARCHAR(120)
    GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,

    specialty VARCHAR(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS fitness_club.class_types (
    class_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS fitness_club.class_sessions (
    session_id SERIAL PRIMARY KEY,

    class_type_id INT NOT NULL,
    trainer_id INT NOT NULL,
    location_id INT NOT NULL,

    start_time TIMESTAMP NOT NULL
        CHECK (start_time::date > DATE '2026-01-01'),

    capacity INT NOT NULL
        CHECK (capacity >= 0),

    FOREIGN KEY (class_type_id)
        REFERENCES fitness_club.class_types(class_type_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (trainer_id)
        REFERENCES fitness_club.trainers(trainer_id)
        ON DELETE RESTRICT,

    FOREIGN KEY (location_id)
        REFERENCES fitness_club.locations(location_id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS fitness_club.member_memberships (
    member_membership_id SERIAL PRIMARY KEY,

    member_id INT NOT NULL,
    plan_id INT NOT NULL,

    start_date DATE NOT NULL,
    end_date DATE,

    FOREIGN KEY (member_id)
        REFERENCES fitness_club.members(member_id)
        ON DELETE CASCADE,

    FOREIGN KEY (plan_id)
        REFERENCES fitness_club.membership_plans(plan_id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS fitness_club.attendance (
    attendance_id SERIAL PRIMARY KEY,

    member_id INT NOT NULL,
    session_id INT NOT NULL,

    status VARCHAR(20)
        DEFAULT 'booked'
        CHECK (
            status IN (
                'booked',
                'attended',
                'cancelled',
                'no_show'
            )
        ),

    UNIQUE(member_id, session_id),

    FOREIGN KEY (member_id)
        REFERENCES fitness_club.members(member_id)
        ON DELETE CASCADE,

    FOREIGN KEY (session_id)
        REFERENCES fitness_club.class_sessions(session_id)
        ON DELETE CASCADE
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'fitness_club';

-- forgot phone number column
ALTER TABLE fitness_club.members
ADD COLUMN phone_number VARCHAR(15);

-- international phone numbers can be longer
ALTER TABLE fitness_club.members
ALTER COLUMN phone_number TYPE VARCHAR(20);

-- add unique constraint for phone numbers
ALTER TABLE fitness_club.members
ADD CONSTRAINT uq_member_phone UNIQUE(phone_number);

-- rename city column for clarity
ALTER TABLE fitness_club.locations
RENAME COLUMN city TO city_name;

-- add default value for phone number
ALTER TABLE fitness_club.members
ALTER COLUMN phone_number SET DEFAULT 'Not Provided';

INSERT INTO fitness_club.locations (name, city_name)
VALUES
('Downtown Club', 'Aktau'),
('West Fitness', 'Aktau'),
('Energy Gym', 'Atyrau'),
('Power House', 'Almaty'),
('Strong Life', 'Astana');

INSERT INTO fitness_club.membership_plans (plan_name, monthly_price)
VALUES
('Basic', 12000),
('Standard', 18000),
('Premium', 25000),
('Student', 9000),
('VIP', 35000);

INSERT INTO fitness_club.members
(first_name, last_name, email, gender, phone_number)
VALUES
('Aruzhan','Bekova','aruzhan@mail.kz','Female','87011111111'),
('Amina','Sarsen','amina@mail.kz','Female','87011111112'),
('Dana','Kairat','dana@mail.kz','Female','87011111113'),
('Ali','Nurgali','ali@mail.kz','Male','87011111114'),
('Dias','Tulegen','dias@mail.kz','Male','87011111115'),
('Miras','Abay','miras@mail.kz','Male','87011111116'),
('Alina','Omarova','alina@mail.kz','Female','87011111117'),
('Nursultan','Aman','nursultan@mail.kz','Male','87011111118'),
('Aigerim','Serik','aigerim@mail.kz','Female','87011111119'),
('Timur','Kenzhe','timur@mail.kz','Male','87011111120');

INSERT INTO fitness_club.trainers
(first_name, last_name, specialty)
VALUES
('Maxim','Ivanov','CrossFit'),
('Anna','Petrova','Yoga'),
('Sergey','Kim','Boxing'),
('Aruzhan','Nur','Pilates'),
('Damir','Askar','Strength Training');

INSERT INTO fitness_club.class_types (name)
VALUES
('Yoga'),
('Boxing'),
('CrossFit'),
('Pilates'),
('HIIT');

INSERT INTO fitness_club.class_sessions
(class_type_id, trainer_id, location_id, start_time, capacity)
VALUES
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Yoga'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Yoga'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Downtown Club'),
 '2026-02-10 09:00:00',
 20
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Boxing'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Boxing'),
 (SELECT location_id FROM fitness_club.locations WHERE name='West Fitness'),
 '2026-02-11 18:00:00',
 15
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='CrossFit'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='CrossFit'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Energy Gym'),
 '2026-02-12 17:00:00',
 25
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Pilates'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Pilates'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Power House'),
 '2026-02-13 10:00:00',
 18
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='HIIT'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Strength Training'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Strong Life'),
 '2026-02-14 19:00:00',
 30
);

INSERT INTO fitness_club.member_memberships
(member_id, plan_id, start_date, end_date)
VALUES
(
 (SELECT member_id FROM fitness_club.members WHERE email='aruzhan@mail.kz'),
 (SELECT plan_id FROM fitness_club.membership_plans WHERE plan_name='Premium'),
 '2026-01-05',
 '2026-12-31'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='amina@mail.kz'),
 (SELECT plan_id FROM fitness_club.membership_plans WHERE plan_name='Student'),
 '2026-01-10',
 '2026-06-30'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='ali@mail.kz'),
 (SELECT plan_id FROM fitness_club.membership_plans WHERE plan_name='Basic'),
 '2026-01-01',
 '2026-12-31'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='dias@mail.kz'),
 (SELECT plan_id FROM fitness_club.membership_plans WHERE plan_name='Standard'),
 '2026-01-15',
 '2026-12-31'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='timur@mail.kz'),
 (SELECT plan_id FROM fitness_club.membership_plans WHERE plan_name='VIP'),
 '2026-01-20',
 '2026-12-31'
);

INSERT INTO fitness_club.attendance
(member_id, session_id, status)
VALUES
(
 (SELECT member_id FROM fitness_club.members WHERE email='aruzhan@mail.kz'),
 (SELECT session_id FROM fitness_club.class_sessions LIMIT 1),
 'attended'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='amina@mail.kz'),
 (SELECT session_id FROM fitness_club.class_sessions LIMIT 1),
 'booked'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='ali@mail.kz'),
 (SELECT session_id FROM fitness_club.class_sessions OFFSET 1 LIMIT 1),
 'attended'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='dias@mail.kz'),
 (SELECT session_id FROM fitness_club.class_sessions OFFSET 2 LIMIT 1),
 'booked'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='timur@mail.kz'),
 (SELECT session_id FROM fitness_club.class_sessions OFFSET 3 LIMIT 1),
 'cancelled'
);

INSERT INTO fitness_club.attendance (member_id, session_id, status)
SELECT
    m.member_id,
    s.session_id,
    'booked'
FROM fitness_club.members m
CROSS JOIN fitness_club.class_sessions s
WHERE m.email = 'alina@mail.kz'
LIMIT 1;

-- VIP membership became more expensive
UPDATE fitness_club.membership_plans
SET monthly_price = 40000
WHERE plan_name = 'VIP';

-- upgrade Timur to Premium membership
UPDATE fitness_club.member_memberships
SET plan_id = (
    SELECT plan_id
    FROM fitness_club.membership_plans
    WHERE plan_name = 'Premium'
)
WHERE member_id = (
    SELECT member_id
    FROM fitness_club.members
    WHERE email = 'timur@mail.kz'
);

BEGIN;

-- remove cancelled attendances
DELETE FROM fitness_club.attendance
WHERE status = 'cancelled'
RETURNING attendance_id;

ROLLBACK;

DROP ROLE IF EXISTS fitness_club_readonly;
DROP ROLE IF EXISTS fitness_club_writer;

CREATE ROLE fitness_club_readonly;
CREATE ROLE fitness_club_writer;

GRANT USAGE ON SCHEMA fitness_club TO fitness_club_readonly;

GRANT SELECT ON ALL TABLES IN SCHEMA fitness_club
TO fitness_club_readonly;

GRANT INSERT, UPDATE
ON fitness_club.members
TO fitness_club_writer;

-- writers may add members but cannot modify them
REVOKE UPDATE
ON fitness_club.members
FROM fitness_club_writer;

SELECT COUNT(*) FROM fitness_club.members;
SELECT COUNT(*) FROM fitness_club.trainers;
SELECT COUNT(*) FROM fitness_club.class_sessions;
SELECT COUNT(*) FROM fitness_club.attendance;

INSERT INTO fitness_club.class_sessions
(class_type_id, trainer_id, location_id, start_time, capacity)
VALUES
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Yoga'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Yoga'),
 (SELECT location_id FROM fitness_club.locations WHERE name='West Fitness'),
 '2026-03-01 10:00:00',
 20
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Boxing'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Boxing'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Energy Gym'),
 '2026-03-02 18:00:00',
 15
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='CrossFit'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='CrossFit'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Power House'),
 '2026-03-03 17:00:00',
 25
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='Pilates'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Pilates'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Strong Life'),
 '2026-03-04 11:00:00',
 18
),
(
 (SELECT class_type_id FROM fitness_club.class_types WHERE name='HIIT'),
 (SELECT trainer_id FROM fitness_club.trainers WHERE specialty='Strength Training'),
 (SELECT location_id FROM fitness_club.locations WHERE name='Downtown Club'),
 '2026-03-05 19:00:00',
 30
);

INSERT INTO fitness_club.attendance
(member_id, session_id, status)
VALUES
(
 (SELECT member_id FROM fitness_club.members WHERE email='dana@mail.kz'),
 5,
 'attended'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='miras@mail.kz'),
 6,
 'booked'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='alina@mail.kz'),
 7,
 'attended'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='nursultan@mail.kz'),
 8,
 'booked'
),
(
 (SELECT member_id FROM fitness_club.members WHERE email='aigerim@mail.kz'),
 9,
 'attended'
);

SELECT COUNT(*) FROM fitness_club.class_sessions;
SELECT COUNT(*) FROM fitness_club.attendance;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'fitness_club';

SELECT *
FROM fitness_club.trainers;