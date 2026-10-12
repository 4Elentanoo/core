-- 02_seed.sql — демо-данные спортивной школы «Жемчужина».
-- Сгенерировано скриптом; все данные вымышленные. Пароль у всех аккаунтов: demo1234 (bcrypt).
-- Перед запуском: 00_reset.sql и 01_schema.sql.
--
-- Принцип: id нигде не пишутся руками (GENERATED ALWAYS). Ссылки ищутся по естественным ключам:
-- аккаунт — по почте, ученик — по почте родителя и имени, зал — по имени, пара — по дню и времени.
--
-- Состояние на 12.10.2026: идёт учебный год 2026/27. В базе есть история прошлого сезона:
-- смена тренера у «Силуэта», закрытая группа «Балет», ушедшие ученики, переезды снарядов.

BEGIN;

-- ============ Справочники
INSERT INTO role (name) VALUES
  ('администратор'),
  ('тренер'),
  ('родитель');
INSERT INTO category (name, level) VALUES
  ('вторая', 1),
  ('первая', 2),
  ('высшая', 3);
INSERT INTO stage (name, lessons_per_week) VALUES
  ('Начальная подготовка, 1-й год', 2),
  ('Начальная подготовка, 2-й год', 3),
  ('Учебно-тренировочный', 4),
  ('Спортивное совершенствование', 4);
INSERT INTO type_sport (name, description) VALUES
  ('Художественная гимнастика', 'Упражнения с предметами под музыку'),
  ('Акробатика', 'Прыжки, перевороты, парные и групповые упражнения'),
  ('ОФП', 'Общая физическая подготовка'),
  ('Растяжка', 'Гибкость и подвижность суставов'),
  ('Хореография', 'Классический экзерсис у станка');
INSERT INTO equipment (name) VALUES
  ('Гимнастический ковёр'),
  ('Набор предметов ХГ'),
  ('Гимнастические маты'),
  ('Шведская стенка'),
  ('Батут'),
  ('Хореографический станок'),
  ('Зеркала');
INSERT INTO lesson_status (name) VALUES
  ('запланировано'),
  ('проведено'),
  ('отменено');
INSERT INTO attendance_status (name) VALUES
  ('присутствовал'),
  ('отсутствовал'),
  ('опоздал');

-- Сетка пар: 6 дней × 8 пар по 1,5 часа с 9:30 (решение 5) — 48 строк одним запросом.
INSERT INTO slot (day_of_week, start_time)
SELECT d, time '09:30' + (p * interval '90 minutes')
FROM generate_series(1, 6) AS d, generate_series(0, 7) AS p
ORDER BY d, p;

-- Требования видов спорта к инвентарю (Ж6)
INSERT INTO section_equipment (type_sport_id, equipment_id)
SELECT ts.id, e.id
FROM (VALUES
  ('Художественная гимнастика', 'Гимнастический ковёр'),
  ('Художественная гимнастика', 'Набор предметов ХГ'),
  ('Акробатика', 'Гимнастические маты'),
  ('Акробатика', 'Батут'),
  ('ОФП', 'Шведская стенка'),
  ('ОФП', 'Гимнастические маты'),
  ('Растяжка', 'Гимнастические маты'),
  ('Хореография', 'Хореографический станок'),
  ('Хореография', 'Зеркала')
) AS v(sport, equip)
JOIN type_sport ts ON ts.name = v.sport
JOIN equipment e ON e.name = v.equip;

-- ============ Залы и инвентарь
INSERT INTO room (name, number, capacity) VALUES
  ('Большой ковровый', 1, 20),
  ('Акробатический', 2, 14),
  ('Хореографический', 3, 16),
  ('Малый', 4, 10);

INSERT INTO item (inventory_number, equipment_id, name, description)
SELECT v.inv, e.id, v.name, v.descr
FROM (VALUES
  ('СШ-0001', 'Гимнастический ковёр', NULL, '13 × 13 м'),
  ('СШ-0002', 'Гимнастический ковёр', NULL, '9 × 9 м'),
  ('СШ-0003', 'Набор предметов ХГ', NULL, 'мячи, ленты, обручи, булавы'),
  ('СШ-0004', 'Набор предметов ХГ', NULL, 'мячи, ленты, обручи, булавы'),
  ('СШ-0005', 'Набор предметов ХГ', NULL, 'мячи, ленты, обручи'),
  ('СШ-0006', 'Гимнастические маты', NULL, NULL),
  ('СШ-0007', 'Гимнастические маты', NULL, NULL),
  ('СШ-0008', 'Гимнастические маты', NULL, NULL),
  ('СШ-0009', 'Гимнастические маты', NULL, NULL),
  ('СШ-0010', 'Гимнастические маты', NULL, NULL),
  ('СШ-0011', 'Гимнастические маты', NULL, NULL),
  ('СШ-0012', 'Гимнастические маты', NULL, NULL),
  ('СШ-0013', 'Гимнастические маты', NULL, NULL),
  ('СШ-0014', 'Гимнастические маты', NULL, NULL),
  ('СШ-0015', 'Гимнастические маты', NULL, NULL),
  ('СШ-0016', 'Гимнастические маты', NULL, NULL),
  ('СШ-0017', 'Гимнастические маты', NULL, NULL),
  ('СШ-0018', 'Гимнастические маты', NULL, NULL),
  ('СШ-0019', 'Гимнастические маты', NULL, NULL),
  ('СШ-0020', 'Гимнастические маты', NULL, NULL),
  ('СШ-0021', 'Шведская стенка', NULL, NULL),
  ('СШ-0022', 'Шведская стенка', NULL, NULL),
  ('СШ-0023', 'Шведская стенка', NULL, NULL),
  ('СШ-0024', 'Батут', 'Батут Eurotramp', NULL),
  ('СШ-0025', 'Хореографический станок', NULL, 'двухуровневый, 6 м'),
  ('СШ-0026', 'Хореографический станок', NULL, 'двухуровневый, 6 м'),
  ('СШ-0027', 'Зеркала', NULL, 'секция 2 × 6 м'),
  ('СШ-0028', 'Зеркала', NULL, 'секция 2 × 6 м'),
  ('СШ-0029', 'Зеркала', NULL, NULL)
) AS v(inv, equip, name, descr)
JOIN equipment e ON e.name = v.equip;

-- Размещения: открытое (date_end пусто) — предмет стоит там сейчас; закрытые — история переездов.
INSERT INTO equipment_placement (item_id, room_id, date_install, date_end)
SELECT i.id, r.id, v.d_from::date, v.d_to::date
FROM (VALUES
  ('СШ-0001', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0002', 'Малый', '2024-09-01', NULL),
  ('СШ-0003', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0004', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0005', 'Малый', '2024-09-01', NULL),
  ('СШ-0006', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0007', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0008', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0009', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0010', 'Акробатический', '2024-09-01', NULL),
  ('СШ-0011', 'Акробатический', '2024-09-01', NULL),
  ('СШ-0012', 'Акробатический', '2024-09-01', NULL),
  ('СШ-0013', 'Акробатический', '2024-09-01', NULL),
  ('СШ-0014', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0015', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0016', 'Малый', '2024-09-01', NULL),
  ('СШ-0017', 'Малый', '2024-09-01', NULL),
  ('СШ-0018', 'Малый', '2024-09-01', NULL),
  ('СШ-0019', 'Малый', '2024-09-01', '2026-02-10'),
  ('СШ-0019', 'Акробатический', '2026-02-10', NULL),
  ('СШ-0020', 'Малый', '2024-09-01', '2026-02-10'),
  ('СШ-0020', 'Акробатический', '2026-02-10', NULL),
  ('СШ-0021', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0022', 'Большой ковровый', '2024-09-01', NULL),
  ('СШ-0023', 'Акробатический', '2024-09-01', NULL),
  ('СШ-0024', 'Большой ковровый', '2024-09-01', '2025-08-20'),
  ('СШ-0024', 'Акробатический', '2025-08-20', NULL),
  ('СШ-0025', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0026', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0027', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0028', 'Хореографический', '2024-09-01', NULL),
  ('СШ-0029', 'Хореографический', '2024-09-01', '2026-05-15'),
  ('СШ-0029', 'Малый', '2026-05-15', NULL)
) AS v(inv, room, d_from, d_to)
JOIN item i ON i.inventory_number = v.inv
JOIN room r ON r.name = v.room;

-- ============ Аккаунты и роли
INSERT INTO account (first_name, last_name, mail, phone, password_hash) VALUES
  ('Елена', 'Кравченко', 'elena.kravchenko@zhemchuzhina.ru', '+7 915 427-74-75', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Анна', 'Белова', 'anna.belova@zhemchuzhina.ru', '+7 982 980-23-38', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Кравец', 'olga.kravets@zhemchuzhina.ru', '+7 976 736-81-63', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Марина', 'Соколова', 'marina.sokolova@zhemchuzhina.ru', '+7 973 660-72-85', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Иван', 'Петров', 'ivan.petrov@zhemchuzhina.ru', '+7 956 345-10-88', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Дмитрий', 'Лебедев', 'dmitriy.lebedev@zhemchuzhina.ru', '+7 910 213-46-22', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Елена', 'Орлова', 'elena.orlova@zhemchuzhina.ru', '+7 957 111-97-72', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Светлана', 'Захарова', 'svetlana.zakharova@zhemchuzhina.ru', '+7 986 421-36-60', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алексей', 'Морозов', 'aleksey.morozov@zhemchuzhina.ru', '+7 932 456-55-58', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Медведева', 'ekaterina.medvedeva@mail.ru', '+7 970 918-92-74', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Сергеева', 'yuliya.sergeeva@mail.ru', '+7 901 133-29-93', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Евгения', 'Ильина', 'evgeniya.ilina@mail.ru', '+7 959 623-73-65', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Васильева', 'olga.vasileva@mail.ru', '+7 956 805-75-43', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Евгения', 'Белова', 'evgeniya.belova@mail.ru', '+7 908 764-44-73', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Андреева', 'aleksandra.andreeva@mail.ru', '+7 901 194-10-67', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Петрова', 'olga.petrova@mail.ru', '+7 979 145-79-44', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Артём', 'Александров', 'artem.aleksandrov@mail.ru', '+7 928 584-85-26', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Наталья', 'Фролова', 'natalya.frolova@mail.ru', '+7 966 926-35-58', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Степанова', 'kseniya.stepanova@mail.ru', '+7 982 461-13-13', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Жукова', 'olga.zhukova@mail.ru', '+7 963 577-83-89', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Вера', 'Григорьева', 'vera.grigoreva@mail.ru', '+7 929 794-18-80', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Надежда', 'Фёдорова', 'nadezhda.fedorova@mail.ru', '+7 906 562-92-34', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Павел', 'Максимов', 'pavel.maksimov@mail.ru', '+7 939 291-54-32', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Ковалёва', 'ekaterina.kovaleva@mail.ru', '+7 959 281-51-76', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Дмитриева', 'yuliya.dmitrieva@mail.ru', '+7 912 968-37-39', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Татьяна', 'Николаева', 'tatyana.nikolaeva@mail.ru', '+7 903 460-30-55', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ирина', 'Смирнова', 'irina.smirnova@mail.ru', '+7 972 401-82-44', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Татьяна', 'Никитина', 'tatyana.nikitina@mail.ru', '+7 982 745-23-74', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Беляева', 'yuliya.belyaeva@mail.ru', '+7 932 164-11-62', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Антонова', 'kseniya.antonova@mail.ru', '+7 940 898-68-87', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Борисова', 'aleksandra.borisova@mail.ru', '+7 954 792-25-97', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Иван', 'Комаров', 'ivan.komarov@mail.ru', '+7 907 853-65-13', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Дмитрий', 'Зайцев', 'dmitriy.zaytsev@mail.ru', '+7 938 886-63-50', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Филиппова', 'olga.filippova@mail.ru', '+7 920 733-25-25', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Михаил', 'Воробьёв', 'mikhail.vorobev@mail.ru', '+7 903 534-84-26', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Светлана', 'Михайлова', 'svetlana.mikhaylova@mail.ru', '+7 999 228-33-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Светлана', 'Гусева', 'svetlana.guseva@mail.ru', '+7 902 116-45-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Баранова', 'alena.baranova@mail.ru', '+7 933 448-91-76', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Мария', 'Алексеева', 'mariya.alekseeva@mail.ru', '+7 928 795-75-29', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Киселёва', 'yuliya.kiseleva@mail.ru', '+7 943 981-35-57', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Полина', 'Павлова', 'polina.pavlova@mail.ru', '+7 939 292-30-90', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Артём', 'Новиков', 'artem.novikov@mail.ru', '+7 989 518-14-91', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Наталья', 'Лебедева', 'natalya.lebedeva@mail.ru', '+7 991 857-22-12', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Павел', 'Тарасов', 'pavel.tarasov@mail.ru', '+7 968 628-92-94', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Наталья', 'Егорова', 'natalya.egorova@mail.ru', '+7 949 293-90-11', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Надежда', 'Яковлева', 'nadezhda.yakovleva@mail.ru', '+7 921 839-76-13', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Богданова', 'ekaterina.bogdanova@mail.ru', '+7 927 644-29-86', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Иванова', 'olga.ivanova@mail.ru', '+7 944 585-73-25', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Виноградова', 'aleksandra.vinogradova@mail.ru', '+7 974 453-20-18', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Светлана', 'Кузьмина', 'svetlana.kuzmina@mail.ru', '+7 921 432-65-74', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Полина', 'Герасимова', 'polina.gerasimova@mail.ru', '+7 948 317-29-66', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Наталья', 'Полякова', 'natalya.polyakova@mail.ru', '+7 971 890-25-44', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Марина', 'Макарова', 'marina.makarova@mail.ru', '+7 986 519-53-22', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Дарья', 'Попова', 'darya.popova@mail.ru', '+7 992 277-11-44', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Евгения', 'Волкова', 'evgeniya.volkova@mail.ru', '+7 961 446-11-14', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ирина', 'Сидорова', 'irina.sidorova@mail.ru', '+7 958 627-45-89', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Соколова', 'ekaterina.sokolova@mail.ru', '+7 910 681-63-76', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Сорокина', 'alena.sorokina@mail.ru', '+7 929 582-94-94', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Михаил', 'Кузнецов', 'mikhail.kuznetsov@mail.ru', '+7 904 759-72-27', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Семёнова', 'yuliya.semenova@mail.ru', '+7 965 962-61-48', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Захарова', 'alena.zakharova@mail.ru', '+7 987 645-48-71', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Елена', 'Козлова', 'elena.kozlova@mail.ru', '+7 971 984-32-42', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алексей', 'Королёв', 'aleksey.korolev@mail.ru', '+7 959 346-36-64', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Евгения', 'Романова', 'evgeniya.romanova@mail.ru', '+7 917 672-96-51', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Вера', 'Осипова', 'vera.osipova@mail.ru', '+7 970 821-29-28', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Орлова', 'ekaterina.orlova@mail.ru', '+7 922 242-44-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Татьяна', 'Морозова', 'tatyana.morozova@mail.ru', '+7 987 257-62-92', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Соловьёва', 'aleksandra.soloveva@mail.ru', '+7 987 865-62-29', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Виктория', 'Давыдова', 'viktoriya.davydova@mail.ru', '+7 984 543-35-31', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Николай', 'Лебедев', 'nikolay.lebedev@mail.ru', '+7 971 721-71-21', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Павел', 'Богданов', 'pavel.bogdanov@mail.ru', '+7 903 660-28-92', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Иван', 'Григорьев', 'ivan.grigorev@mail.ru', '+7 962 241-23-28', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Артём', 'Попов', 'artem.popov@mail.ru', '+7 941 873-42-97', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Кузьмина', 'olga.kuzmina@mail.ru', '+7 935 403-14-20', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Максимова', 'aleksandra.maksimova@mail.ru', '+7 978 590-79-12', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Юлия', 'Морозова', 'yuliya.morozova@mail.ru', '+7 902 147-19-87', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Романова', 'aleksandra.romanova@mail.ru', '+7 988 348-61-40', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Яковлева', 'olga.yakovleva@mail.ru', '+7 975 587-85-58', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Белова', 'aleksandra.belova@mail.ru', '+7 917 401-40-76', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Макарова', 'alena.makarova@mail.ru', '+7 921 643-25-82', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Григорьева', 'olga.grigoreva@mail.ru', '+7 913 924-63-61', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Морозова', 'kseniya.morozova@mail.ru', '+7 910 361-31-14', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Кузнецова', 'aleksandra.kuznetsova@mail.ru', '+7 965 745-14-34', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Козлова', 'ekaterina.kozlova@mail.ru', '+7 979 761-15-70', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Мария', 'Фролова', 'mariya.frolova@mail.ru', '+7 969 460-39-78', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Светлана', 'Киселёва', 'svetlana.kiseleva@mail.ru', '+7 921 672-35-74', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Елена', 'Максимова', 'elena.maksimova@mail.ru', '+7 902 452-19-26', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Марина', 'Фёдорова', 'marina.fedorova@mail.ru', '+7 922 606-80-24', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Полина', 'Макарова', 'polina.makarova@mail.ru', '+7 902 765-42-40', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Полина', 'Гусева', 'polina.guseva@mail.ru', '+7 922 414-78-11', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Евгения', 'Королёва', 'evgeniya.koroleva@mail.ru', '+7 996 262-87-74', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Смирнова', 'ekaterina.smirnova@mail.ru', '+7 919 490-91-90', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Козлова', 'aleksandra.kozlova@mail.ru', '+7 993 950-48-42', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Татьяна', 'Беляева', 'tatyana.belyaeva@mail.ru', '+7 913 727-80-13', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Андрей', 'Антонов', 'andrey.antonov@mail.ru', '+7 988 780-51-31', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Михаил', 'Фролов', 'mikhail.frolov@mail.ru', '+7 944 986-67-41', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Татьяна', 'Филиппова', 'tatyana.filippova@mail.ru', '+7 955 786-84-26', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Мария', 'Киселёва', 'mariya.kiseleva@mail.ru', '+7 976 626-53-81', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Надежда', 'Виноградова', 'nadezhda.vinogradova@mail.ru', '+7 965 392-95-88', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Виктория', 'Кузьмина', 'viktoriya.kuzmina@mail.ru', '+7 967 539-59-89', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Анна', 'Захарова', 'anna.zakharova@mail.ru', '+7 913 341-37-32', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Филиппова', 'alena.filippova@mail.ru', '+7 924 482-13-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Михайлова', 'kseniya.mikhaylova@mail.ru', '+7 981 628-90-22', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Елена', 'Иванова', 'elena.ivanova@mail.ru', '+7 997 449-94-29', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Волкова', 'kseniya.volkova@mail.ru', '+7 930 252-66-69', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Новикова', 'aleksandra.novikova@mail.ru', '+7 954 997-18-66', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Анна', 'Беляева', 'anna.belyaeva@mail.ru', '+7 925 715-86-53', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Дмитрий', 'Осипов', 'dmitriy.osipov@mail.ru', '+7 984 444-61-92', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ксения', 'Захарова', 'kseniya.zakharova@mail.ru', '+7 955 873-97-67', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Дарья', 'Иванова', 'darya.ivanova@mail.ru', '+7 994 459-42-71', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Вера', 'Соловьёва', 'vera.soloveva@mail.ru', '+7 902 984-47-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Екатерина', 'Борисова', 'ekaterina.borisova@mail.ru', '+7 990 363-10-36', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Мария', 'Васильева', 'mariya.vasileva@mail.ru', '+7 990 475-89-79', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Алёна', 'Сорокина', 'alena.sorokina2@mail.ru', '+7 981 732-16-47', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Ольга', 'Беляева', 'olga.belyaeva@mail.ru', '+7 988 168-23-19', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Надежда', 'Новикова', 'nadezhda.novikova@mail.ru', '+7 994 124-46-62', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Александра', 'Сорокина', 'aleksandra.sorokina@mail.ru', '+7 924 152-63-49', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6'),
  ('Артём', 'Ильин', 'artem.ilin@mail.ru', '+7 921 721-60-16', '$2b$10$z7E.bMvfKAe/KW/zJdiR9OYKJU4/gzHGMLCqa0qJs2QSL4ll4deV6');

INSERT INTO account_role (account_id, role_id)
SELECT a.id, r.id
FROM (VALUES
  ('elena.kravchenko@zhemchuzhina.ru', 'администратор'),
  ('anna.belova@zhemchuzhina.ru', 'тренер'),
  ('anna.belova@zhemchuzhina.ru', 'родитель'),
  ('olga.kravets@zhemchuzhina.ru', 'тренер'),
  ('marina.sokolova@zhemchuzhina.ru', 'тренер'),
  ('ivan.petrov@zhemchuzhina.ru', 'тренер'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 'тренер'),
  ('elena.orlova@zhemchuzhina.ru', 'тренер'),
  ('svetlana.zakharova@zhemchuzhina.ru', 'тренер'),
  ('aleksey.morozov@zhemchuzhina.ru', 'тренер'),
  ('ekaterina.medvedeva@mail.ru', 'родитель'),
  ('yuliya.sergeeva@mail.ru', 'родитель'),
  ('evgeniya.ilina@mail.ru', 'родитель'),
  ('olga.vasileva@mail.ru', 'родитель'),
  ('evgeniya.belova@mail.ru', 'родитель'),
  ('aleksandra.andreeva@mail.ru', 'родитель'),
  ('olga.petrova@mail.ru', 'родитель'),
  ('artem.aleksandrov@mail.ru', 'родитель'),
  ('natalya.frolova@mail.ru', 'родитель'),
  ('kseniya.stepanova@mail.ru', 'родитель'),
  ('olga.zhukova@mail.ru', 'родитель'),
  ('vera.grigoreva@mail.ru', 'родитель'),
  ('nadezhda.fedorova@mail.ru', 'родитель'),
  ('pavel.maksimov@mail.ru', 'родитель'),
  ('ekaterina.kovaleva@mail.ru', 'родитель'),
  ('yuliya.dmitrieva@mail.ru', 'родитель'),
  ('tatyana.nikolaeva@mail.ru', 'родитель'),
  ('irina.smirnova@mail.ru', 'родитель'),
  ('tatyana.nikitina@mail.ru', 'родитель'),
  ('yuliya.belyaeva@mail.ru', 'родитель'),
  ('kseniya.antonova@mail.ru', 'родитель'),
  ('aleksandra.borisova@mail.ru', 'родитель'),
  ('ivan.komarov@mail.ru', 'родитель'),
  ('dmitriy.zaytsev@mail.ru', 'родитель'),
  ('olga.filippova@mail.ru', 'родитель'),
  ('mikhail.vorobev@mail.ru', 'родитель'),
  ('svetlana.mikhaylova@mail.ru', 'родитель'),
  ('svetlana.guseva@mail.ru', 'родитель'),
  ('alena.baranova@mail.ru', 'родитель'),
  ('mariya.alekseeva@mail.ru', 'родитель'),
  ('yuliya.kiseleva@mail.ru', 'родитель'),
  ('polina.pavlova@mail.ru', 'родитель'),
  ('artem.novikov@mail.ru', 'родитель'),
  ('natalya.lebedeva@mail.ru', 'родитель'),
  ('pavel.tarasov@mail.ru', 'родитель'),
  ('natalya.egorova@mail.ru', 'родитель'),
  ('nadezhda.yakovleva@mail.ru', 'родитель'),
  ('ekaterina.bogdanova@mail.ru', 'родитель'),
  ('olga.ivanova@mail.ru', 'родитель'),
  ('aleksandra.vinogradova@mail.ru', 'родитель'),
  ('svetlana.kuzmina@mail.ru', 'родитель'),
  ('polina.gerasimova@mail.ru', 'родитель'),
  ('natalya.polyakova@mail.ru', 'родитель'),
  ('marina.makarova@mail.ru', 'родитель'),
  ('darya.popova@mail.ru', 'родитель'),
  ('evgeniya.volkova@mail.ru', 'родитель'),
  ('irina.sidorova@mail.ru', 'родитель'),
  ('ekaterina.sokolova@mail.ru', 'родитель'),
  ('alena.sorokina@mail.ru', 'родитель'),
  ('mikhail.kuznetsov@mail.ru', 'родитель'),
  ('yuliya.semenova@mail.ru', 'родитель'),
  ('alena.zakharova@mail.ru', 'родитель'),
  ('elena.kozlova@mail.ru', 'родитель'),
  ('aleksey.korolev@mail.ru', 'родитель'),
  ('evgeniya.romanova@mail.ru', 'родитель'),
  ('vera.osipova@mail.ru', 'родитель'),
  ('ekaterina.orlova@mail.ru', 'родитель'),
  ('tatyana.morozova@mail.ru', 'родитель'),
  ('aleksandra.soloveva@mail.ru', 'родитель'),
  ('viktoriya.davydova@mail.ru', 'родитель'),
  ('nikolay.lebedev@mail.ru', 'родитель'),
  ('pavel.bogdanov@mail.ru', 'родитель'),
  ('ivan.grigorev@mail.ru', 'родитель'),
  ('artem.popov@mail.ru', 'родитель'),
  ('olga.kuzmina@mail.ru', 'родитель'),
  ('aleksandra.maksimova@mail.ru', 'родитель'),
  ('yuliya.morozova@mail.ru', 'родитель'),
  ('aleksandra.romanova@mail.ru', 'родитель'),
  ('olga.yakovleva@mail.ru', 'родитель'),
  ('aleksandra.belova@mail.ru', 'родитель'),
  ('alena.makarova@mail.ru', 'родитель'),
  ('olga.grigoreva@mail.ru', 'родитель'),
  ('kseniya.morozova@mail.ru', 'родитель'),
  ('aleksandra.kuznetsova@mail.ru', 'родитель'),
  ('ekaterina.kozlova@mail.ru', 'родитель'),
  ('mariya.frolova@mail.ru', 'родитель'),
  ('svetlana.kiseleva@mail.ru', 'родитель'),
  ('elena.maksimova@mail.ru', 'родитель'),
  ('marina.fedorova@mail.ru', 'родитель'),
  ('polina.makarova@mail.ru', 'родитель'),
  ('polina.guseva@mail.ru', 'родитель'),
  ('evgeniya.koroleva@mail.ru', 'родитель'),
  ('ekaterina.smirnova@mail.ru', 'родитель'),
  ('aleksandra.kozlova@mail.ru', 'родитель'),
  ('tatyana.belyaeva@mail.ru', 'родитель'),
  ('andrey.antonov@mail.ru', 'родитель'),
  ('mikhail.frolov@mail.ru', 'родитель'),
  ('tatyana.filippova@mail.ru', 'родитель'),
  ('mariya.kiseleva@mail.ru', 'родитель'),
  ('nadezhda.vinogradova@mail.ru', 'родитель'),
  ('viktoriya.kuzmina@mail.ru', 'родитель'),
  ('anna.zakharova@mail.ru', 'родитель'),
  ('alena.filippova@mail.ru', 'родитель'),
  ('kseniya.mikhaylova@mail.ru', 'родитель'),
  ('elena.ivanova@mail.ru', 'родитель'),
  ('kseniya.volkova@mail.ru', 'родитель'),
  ('aleksandra.novikova@mail.ru', 'родитель'),
  ('anna.belyaeva@mail.ru', 'родитель'),
  ('dmitriy.osipov@mail.ru', 'родитель'),
  ('kseniya.zakharova@mail.ru', 'родитель'),
  ('darya.ivanova@mail.ru', 'родитель'),
  ('vera.soloveva@mail.ru', 'родитель'),
  ('ekaterina.borisova@mail.ru', 'родитель'),
  ('mariya.vasileva@mail.ru', 'родитель'),
  ('alena.sorokina2@mail.ru', 'родитель'),
  ('olga.belyaeva@mail.ru', 'родитель'),
  ('nadezhda.novikova@mail.ru', 'родитель'),
  ('aleksandra.sorokina@mail.ru', 'родитель'),
  ('artem.ilin@mail.ru', 'родитель')
) AS v(mail, role)
JOIN account a ON lower(a.mail) = lower(v.mail)
JOIN role r ON r.name = v.role;

-- ============ Тренеры
INSERT INTO trainer (account_id)
SELECT a.id FROM account a
WHERE lower(a.mail) IN ('anna.belova@zhemchuzhina.ru', 'olga.kravets@zhemchuzhina.ru', 'marina.sokolova@zhemchuzhina.ru', 'ivan.petrov@zhemchuzhina.ru', 'dmitriy.lebedev@zhemchuzhina.ru', 'elena.orlova@zhemchuzhina.ru', 'svetlana.zakharova@zhemchuzhina.ru', 'aleksey.morozov@zhemchuzhina.ru')
ORDER BY a.id;

-- История категорий: текущая категория тренера — последняя по дате.
INSERT INTO trainer_category (trainer_id, category_id, assigned_at)
SELECT t.id, c.id, v.d::date
FROM (VALUES
  ('anna.belova@zhemchuzhina.ru', 'первая', '2015-03-12'),
  ('anna.belova@zhemchuzhina.ru', 'высшая', '2021-04-20'),
  ('olga.kravets@zhemchuzhina.ru', 'первая', '2020-02-14'),
  ('marina.sokolova@zhemchuzhina.ru', 'вторая', '2019-05-15'),
  ('marina.sokolova@zhemchuzhina.ru', 'первая', '2024-04-10'),
  ('ivan.petrov@zhemchuzhina.ru', 'первая', '2010-03-01'),
  ('ivan.petrov@zhemchuzhina.ru', 'высшая', '2016-03-22'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 'первая', '2022-11-30'),
  ('elena.orlova@zhemchuzhina.ru', 'вторая', '2017-06-01'),
  ('elena.orlova@zhemchuzhina.ru', 'первая', '2023-05-18'),
  ('svetlana.zakharova@zhemchuzhina.ru', 'вторая', '2023-12-05'),
  ('aleksey.morozov@zhemchuzhina.ru', 'вторая', '2024-10-01')
) AS v(mail, cat, d)
JOIN account a ON lower(a.mail) = lower(v.mail)
JOIN trainer t ON t.account_id = a.id
JOIN category c ON c.name = v.cat;

INSERT INTO trainer_for_sport (trainer_id, type_sport_id, date_assignment)
SELECT t.id, ts.id, v.d::date
FROM (VALUES
  ('anna.belova@zhemchuzhina.ru', 'Художественная гимнастика', '2012-09-01'),
  ('anna.belova@zhemchuzhina.ru', 'Хореография', '2018-09-01'),
  ('olga.kravets@zhemchuzhina.ru', 'Художественная гимнастика', '2016-09-01'),
  ('marina.sokolova@zhemchuzhina.ru', 'Художественная гимнастика', '2019-09-01'),
  ('marina.sokolova@zhemchuzhina.ru', 'Растяжка', '2021-09-01'),
  ('ivan.petrov@zhemchuzhina.ru', 'ОФП', '2008-09-01'),
  ('ivan.petrov@zhemchuzhina.ru', 'Акробатика', '2008-09-01'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 'Акробатика', '2018-09-01'),
  ('elena.orlova@zhemchuzhina.ru', 'Хореография', '2015-09-01'),
  ('elena.orlova@zhemchuzhina.ru', 'Растяжка', '2020-09-01'),
  ('svetlana.zakharova@zhemchuzhina.ru', 'Художественная гимнастика', '2022-09-01'),
  ('aleksey.morozov@zhemchuzhina.ru', 'ОФП', '2023-09-01')
) AS v(mail, sport, d)
JOIN account a ON lower(a.mail) = lower(v.mail)
JOIN trainer t ON t.account_id = a.id
JOIN type_sport ts ON ts.name = v.sport;

-- Доступность вводится интервалами и раскладывается в пары (решение 8): пара попадает, если начинается внутри интервала.
INSERT INTO trainer_availability (trainer_id, slot_id)
SELECT t.id, s.id
FROM (VALUES
  ('anna.belova@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('anna.belova@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('anna.belova@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('anna.belova@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('anna.belova@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('anna.belova@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('olga.kravets@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('olga.kravets@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('olga.kravets@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('olga.kravets@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('olga.kravets@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('olga.kravets@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('marina.sokolova@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('marina.sokolova@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('marina.sokolova@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('marina.sokolova@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('marina.sokolova@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('ivan.petrov@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('ivan.petrov@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('ivan.petrov@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('ivan.petrov@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('ivan.petrov@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('ivan.petrov@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('dmitriy.lebedev@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('elena.orlova@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('elena.orlova@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('elena.orlova@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('elena.orlova@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('elena.orlova@zhemchuzhina.ru', 6, '09:30', '15:30'),
  ('svetlana.zakharova@zhemchuzhina.ru', 1, '15:30', '21:30'),
  ('svetlana.zakharova@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('svetlana.zakharova@zhemchuzhina.ru', 3, '15:30', '21:30'),
  ('svetlana.zakharova@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('svetlana.zakharova@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('aleksey.morozov@zhemchuzhina.ru', 2, '15:30', '21:30'),
  ('aleksey.morozov@zhemchuzhina.ru', 4, '15:30', '21:30'),
  ('aleksey.morozov@zhemchuzhina.ru', 5, '15:30', '21:30'),
  ('aleksey.morozov@zhemchuzhina.ru', 6, '09:30', '15:30')
) AS v(mail, dow, t_from, t_to)
JOIN account a ON lower(a.mail) = lower(v.mail)
JOIN trainer t ON t.account_id = a.id
JOIN slot s ON s.day_of_week = v.dow
  AND s.start_time >= v.t_from::time
  AND s.start_time + interval '90 minutes' <= v.t_to::time;

-- ============ Группы
INSERT INTO training_group (name, type_sport_id, stage_id, max_students, is_active, min_category_id)
SELECT v.name, ts.id, st.id, v.mx, v.active, c.id
FROM (VALUES
  ('Силуэт', 'Художественная гимнастика', 'Учебно-тренировочный', 12, TRUE, 'первая'),
  ('Гармония', 'Художественная гимнастика', 'Начальная подготовка, 2-й год', 14, TRUE, 'вторая'),
  ('Пластика', 'Художественная гимнастика', 'Начальная подготовка, 1-й год', 14, TRUE, 'вторая'),
  ('Жемчужинки', 'Художественная гимнастика', 'Начальная подготовка, 1-й год', 10, TRUE, 'вторая'),
  ('Грация', 'Художественная гимнастика', 'Спортивное совершенствование', 10, TRUE, 'высшая'),
  ('Сальто', 'Акробатика', 'Начальная подготовка, 2-й год', 12, TRUE, 'вторая'),
  ('Пирамида', 'Акробатика', 'Учебно-тренировочный', 10, TRUE, 'первая'),
  ('Атлет', 'ОФП', 'Начальная подготовка, 1-й год', 14, TRUE, 'вторая'),
  ('Сила', 'ОФП', 'Начальная подготовка, 2-й год', 14, TRUE, 'вторая'),
  ('Гибкость', 'Растяжка', 'Начальная подготовка, 1-й год', 10, TRUE, 'вторая'),
  ('Шпагат', 'Растяжка', 'Начальная подготовка, 2-й год', 10, TRUE, 'вторая'),
  ('Па-де-де', 'Хореография', 'Начальная подготовка, 2-й год', 16, TRUE, 'первая'),
  ('Балет', 'Хореография', 'Начальная подготовка, 1-й год', 12, FALSE, 'вторая')
) AS v(name, sport, stage, mx, active, min_cat)
JOIN type_sport ts ON ts.name = v.sport
JOIN stage st ON st.name = v.stage
JOIN category c ON c.name = v.min_cat;

-- Тренер группы через «тренер по виду спорта»: вид спорта записи совпадает с видом спорта группы.
INSERT INTO group_trainer (training_group_id, trainer_for_sport_id, start_date, end_date)
SELECT g.id, tfs.id, v.d_from::date, v.d_to::date
FROM (VALUES
  ('Силуэт', 'anna.belova@zhemchuzhina.ru', '2025-09-01', '2026-06-01'),
  ('Силуэт', 'olga.kravets@zhemchuzhina.ru', '2026-06-01', NULL),
  ('Гармония', 'marina.sokolova@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Пластика', 'svetlana.zakharova@zhemchuzhina.ru', '2026-09-01', NULL),
  ('Жемчужинки', 'svetlana.zakharova@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Грация', 'anna.belova@zhemchuzhina.ru', '2024-09-01', NULL),
  ('Сальто', 'dmitriy.lebedev@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Пирамида', 'ivan.petrov@zhemchuzhina.ru', '2024-09-01', NULL),
  ('Атлет', 'aleksey.morozov@zhemchuzhina.ru', '2026-09-01', NULL),
  ('Сила', 'ivan.petrov@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Гибкость', 'marina.sokolova@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Шпагат', 'elena.orlova@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Па-де-де', 'elena.orlova@zhemchuzhina.ru', '2025-09-01', NULL),
  ('Балет', 'anna.belova@zhemchuzhina.ru', '2024-09-01', '2026-06-01')
) AS v(grp, mail, d_from, d_to)
JOIN training_group g ON g.name = v.grp
JOIN account a ON lower(a.mail) = lower(v.mail)
JOIN trainer t ON t.account_id = a.id
JOIN trainer_for_sport tfs ON tfs.trainer_id = t.id AND tfs.type_sport_id = g.type_sport_id;

-- ============ Ученики
INSERT INTO student (first_name, last_name, parent_id, birth_year)
SELECT v.first, v.last, a.id, v.by
FROM (VALUES
  ('Ева', 'Белова', 'anna.belova@zhemchuzhina.ru', 2018),
  ('Арина', 'Медведева', 'ekaterina.medvedeva@mail.ru', 2015),
  ('Злата', 'Сергеева', 'yuliya.sergeeva@mail.ru', 2015),
  ('Валерия', 'Ильина', 'evgeniya.ilina@mail.ru', 2015),
  ('Диана', 'Васильева', 'olga.vasileva@mail.ru', 2014),
  ('Варвара', 'Белова', 'evgeniya.belova@mail.ru', 2014),
  ('Мирослава', 'Андреева', 'aleksandra.andreeva@mail.ru', 2015),
  ('Маргарита', 'Петрова', 'olga.petrova@mail.ru', 2015),
  ('Дарья', 'Ильина', 'evgeniya.ilina@mail.ru', 2015),
  ('Ангелина', 'Александрова', 'artem.aleksandrov@mail.ru', 2015),
  ('Алёна', 'Ильина', 'evgeniya.ilina@mail.ru', 2013),
  ('Варвара', 'Фролова', 'natalya.frolova@mail.ru', 2013),
  ('Арина', 'Степанова', 'kseniya.stepanova@mail.ru', 2015),
  ('Вероника', 'Жукова', 'olga.zhukova@mail.ru', 2016),
  ('Алиса', 'Григорьева', 'vera.grigoreva@mail.ru', 2017),
  ('Елизавета', 'Фёдорова', 'nadezhda.fedorova@mail.ru', 2017),
  ('Яна', 'Фролова', 'natalya.frolova@mail.ru', 2016),
  ('Полина', 'Ильина', 'evgeniya.ilina@mail.ru', 2017),
  ('Злата', 'Максимова', 'pavel.maksimov@mail.ru', 2017),
  ('Злата', 'Ковалёва', 'ekaterina.kovaleva@mail.ru', 2017),
  ('Ева', 'Дмитриева', 'yuliya.dmitrieva@mail.ru', 2016),
  ('Варвара', 'Николаева', 'tatyana.nikolaeva@mail.ru', 2016),
  ('Варвара', 'Смирнова', 'irina.smirnova@mail.ru', 2016),
  ('Варвара', 'Максимова', 'pavel.maksimov@mail.ru', 2016),
  ('Полина', 'Никитина', 'tatyana.nikitina@mail.ru', 2017),
  ('Таисия', 'Беляева', 'yuliya.belyaeva@mail.ru', 2017),
  ('Виктория', 'Александрова', 'artem.aleksandrov@mail.ru', 2016),
  ('Диана', 'Антонова', 'kseniya.antonova@mail.ru', 2018),
  ('Алёна', 'Борисова', 'aleksandra.borisova@mail.ru', 2019),
  ('Елизавета', 'Комарова', 'ivan.komarov@mail.ru', 2019),
  ('Мирослава', 'Зайцева', 'dmitriy.zaytsev@mail.ru', 2018),
  ('Вероника', 'Филиппова', 'olga.filippova@mail.ru', 2018),
  ('Таисия', 'Воробьёва', 'mikhail.vorobev@mail.ru', 2019),
  ('Валерия', 'Михайлова', 'svetlana.mikhaylova@mail.ru', 2018),
  ('Таисия', 'Гусева', 'svetlana.guseva@mail.ru', 2019),
  ('Яна', 'Антонова', 'kseniya.antonova@mail.ru', 2018),
  ('Алиса', 'Баранова', 'alena.baranova@mail.ru', 2019),
  ('Елизавета', 'Алексеева', 'mariya.alekseeva@mail.ru', 2019),
  ('Злата', 'Киселёва', 'yuliya.kiseleva@mail.ru', 2019),
  ('Вероника', 'Павлова', 'polina.pavlova@mail.ru', 2019),
  ('Ева', 'Новикова', 'artem.novikov@mail.ru', 2018),
  ('Алёна', 'Лебедева', 'natalya.lebedeva@mail.ru', 2018),
  ('Кира', 'Тарасова', 'pavel.tarasov@mail.ru', 2018),
  ('Дарья', 'Филиппова', 'olga.filippova@mail.ru', 2019),
  ('Диана', 'Фёдорова', 'nadezhda.fedorova@mail.ru', 2010),
  ('Агата', 'Егорова', 'natalya.egorova@mail.ru', 2012),
  ('Василиса', 'Яковлева', 'nadezhda.yakovleva@mail.ru', 2010),
  ('Елизавета', 'Александрова', 'artem.aleksandrov@mail.ru', 2012),
  ('Мария', 'Богданова', 'ekaterina.bogdanova@mail.ru', 2012),
  ('Варвара', 'Антонова', 'kseniya.antonova@mail.ru', 2011),
  ('Кира', 'Иванова', 'olga.ivanova@mail.ru', 2012),
  ('Николь', 'Виноградова', 'aleksandra.vinogradova@mail.ru', 2010),
  ('Василиса', 'Кузьмина', 'svetlana.kuzmina@mail.ru', 2012),
  ('Ангелина', 'Алексеева', 'mariya.alekseeva@mail.ru', 2016),
  ('Иван', 'Герасимов', 'polina.gerasimova@mail.ru', 2016),
  ('Виктория', 'Смирнова', 'irina.smirnova@mail.ru', 2017),
  ('Дарья', 'Полякова', 'natalya.polyakova@mail.ru', 2017),
  ('Мирон', 'Макаров', 'marina.makarova@mail.ru', 2017),
  ('Вероника', 'Попова', 'darya.popova@mail.ru', 2017),
  ('Кирилл', 'Волков', 'evgeniya.volkova@mail.ru', 2016),
  ('Максим', 'Сидоров', 'irina.sidorova@mail.ru', 2017),
  ('Василиса', 'Петрова', 'olga.petrova@mail.ru', 2016),
  ('Максим', 'Соколов', 'ekaterina.sokolova@mail.ru', 2016),
  ('Василиса', 'Сорокина', 'alena.sorokina@mail.ru', 2017),
  ('Михаил', 'Кузнецов', 'mikhail.kuznetsov@mail.ru', 2013),
  ('Дарья', 'Семёнова', 'yuliya.semenova@mail.ru', 2013),
  ('Максим', 'Захаров', 'alena.zakharova@mail.ru', 2015),
  ('Кира', 'Козлова', 'elena.kozlova@mail.ru', 2015),
  ('Арсений', 'Королёв', 'aleksey.korolev@mail.ru', 2015),
  ('Агата', 'Романова', 'evgeniya.romanova@mail.ru', 2014),
  ('Николь', 'Осипова', 'vera.osipova@mail.ru', 2013),
  ('Тимофей', 'Орлов', 'ekaterina.orlova@mail.ru', 2015),
  ('Арина', 'Морозова', 'tatyana.morozova@mail.ru', 2015),
  ('Вероника', 'Соловьёва', 'aleksandra.soloveva@mail.ru', 2019),
  ('Василиса', 'Комарова', 'ivan.komarov@mail.ru', 2019),
  ('Мария', 'Давыдова', 'viktoriya.davydova@mail.ru', 2018),
  ('Стефания', 'Осипова', 'vera.osipova@mail.ru', 2019),
  ('Стефания', 'Лебедева', 'nikolay.lebedev@mail.ru', 2018),
  ('Варвара', 'Волкова', 'evgeniya.volkova@mail.ru', 2018),
  ('Виктория', 'Богданова', 'pavel.bogdanov@mail.ru', 2019),
  ('Ульяна', 'Григорьева', 'ivan.grigorev@mail.ru', 2018),
  ('Злата', 'Попова', 'artem.popov@mail.ru', 2018),
  ('Ева', 'Кузьмина', 'olga.kuzmina@mail.ru', 2018),
  ('Мирон', 'Максимов', 'aleksandra.maksimova@mail.ru', 2018),
  ('Стефания', 'Морозова', 'yuliya.morozova@mail.ru', 2016),
  ('Иван', 'Романов', 'aleksandra.romanova@mail.ru', 2017),
  ('Кира', 'Яковлева', 'olga.yakovleva@mail.ru', 2017),
  ('Полина', 'Белова', 'aleksandra.belova@mail.ru', 2017),
  ('Роман', 'Макаров', 'alena.makarova@mail.ru', 2017),
  ('Марк', 'Григорьев', 'olga.grigoreva@mail.ru', 2016),
  ('Елизавета', 'Морозова', 'kseniya.morozova@mail.ru', 2016),
  ('Артём', 'Кузнецов', 'aleksandra.kuznetsova@mail.ru', 2017),
  ('Ева', 'Козлова', 'ekaterina.kozlova@mail.ru', 2017),
  ('Злата', 'Фролова', 'mariya.frolova@mail.ru', 2017),
  ('Дарья', 'Козлова', 'elena.kozlova@mail.ru', 2019),
  ('Есения', 'Киселёва', 'svetlana.kiseleva@mail.ru', 2019),
  ('Яна', 'Максимова', 'elena.maksimova@mail.ru', 2018),
  ('София', 'Фёдорова', 'marina.fedorova@mail.ru', 2018),
  ('Елизавета', 'Попова', 'artem.popov@mail.ru', 2019),
  ('Есения', 'Макарова', 'polina.makarova@mail.ru', 2018),
  ('Василиса', 'Гусева', 'polina.guseva@mail.ru', 2018),
  ('Варвара', 'Королёва', 'evgeniya.koroleva@mail.ru', 2019),
  ('Вероника', 'Романова', 'aleksandra.romanova@mail.ru', 2017),
  ('Злата', 'Смирнова', 'ekaterina.smirnova@mail.ru', 2016),
  ('Николь', 'Герасимова', 'polina.gerasimova@mail.ru', 2017),
  ('Стефания', 'Козлова', 'aleksandra.kozlova@mail.ru', 2017),
  ('Анна', 'Беляева', 'tatyana.belyaeva@mail.ru', 2016),
  ('Мария', 'Антонова', 'andrey.antonov@mail.ru', 2016),
  ('Анна', 'Полякова', 'natalya.polyakova@mail.ru', 2017),
  ('Кира', 'Фролова', 'mikhail.frolov@mail.ru', 2016),
  ('Есения', 'Филиппова', 'tatyana.filippova@mail.ru', 2017),
  ('Яна', 'Киселёва', 'mariya.kiseleva@mail.ru', 2017),
  ('Яна', 'Виноградова', 'nadezhda.vinogradova@mail.ru', 2017),
  ('Алёна', 'Кузьмина', 'viktoriya.kuzmina@mail.ru', 2017),
  ('Ксения', 'Захарова', 'anna.zakharova@mail.ru', 2017),
  ('Варвара', 'Филиппова', 'alena.filippova@mail.ru', 2016),
  ('Мария', 'Михайлова', 'kseniya.mikhaylova@mail.ru', 2017),
  ('Агата', 'Иванова', 'elena.ivanova@mail.ru', 2017),
  ('Диана', 'Максимова', 'pavel.maksimov@mail.ru', 2016),
  ('Диана', 'Волкова', 'kseniya.volkova@mail.ru', 2016),
  ('Алиса', 'Новикова', 'aleksandra.novikova@mail.ru', 2017),
  ('Стефания', 'Беляева', 'anna.belyaeva@mail.ru', 2017),
  ('Егор', 'Осипов', 'dmitriy.osipov@mail.ru', 2017),
  ('Тимофей', 'Захаров', 'kseniya.zakharova@mail.ru', 2017),
  ('Ульяна', 'Иванова', 'darya.ivanova@mail.ru', 2016),
  ('Василиса', 'Соловьёва', 'vera.soloveva@mail.ru', 2018),
  ('Алиса', 'Борисова', 'ekaterina.borisova@mail.ru', 2017),
  ('Варвара', 'Васильева', 'mariya.vasileva@mail.ru', 2018),
  ('Варвара', 'Сорокина', 'alena.sorokina2@mail.ru', 2017),
  ('Алиса', 'Беляева', 'olga.belyaeva@mail.ru', 2018),
  ('Мирослава', 'Новикова', 'nadezhda.novikova@mail.ru', 2018),
  ('Полина', 'Сорокина', 'aleksandra.sorokina@mail.ru', 2017),
  ('Злата', 'Ильина', 'artem.ilin@mail.ru', 2017)
) AS v(first, last, parent_mail, by)
JOIN account a ON lower(a.mail) = lower(v.parent_mail);

-- Членство в группах: пустой end_date — занимается сейчас. Периоды полуоткрытые (решение 19).
INSERT INTO student_group (student_id, training_group_id, start_date, end_date)
SELECT s.id, g.id, v.d_from::date, v.d_to::date
FROM (VALUES
  ('anna.belova@zhemchuzhina.ru', 'Ева', 'Пластика', '2026-09-01', NULL),
  ('ekaterina.medvedeva@mail.ru', 'Арина', 'Силуэт', '2026-01-12', NULL),
  ('yuliya.sergeeva@mail.ru', 'Злата', 'Силуэт', '2026-01-12', NULL),
  ('olga.vasileva@mail.ru', 'Диана', 'Силуэт', '2025-09-01', NULL),
  ('evgeniya.belova@mail.ru', 'Варвара', 'Силуэт', '2025-09-01', NULL),
  ('aleksandra.andreeva@mail.ru', 'Мирослава', 'Силуэт', '2025-09-01', NULL),
  ('olga.petrova@mail.ru', 'Маргарита', 'Силуэт', '2026-09-01', NULL),
  ('evgeniya.ilina@mail.ru', 'Дарья', 'Силуэт', '2026-01-12', NULL),
  ('artem.aleksandrov@mail.ru', 'Ангелина', 'Силуэт', '2026-09-01', NULL),
  ('evgeniya.ilina@mail.ru', 'Алёна', 'Силуэт', '2026-09-01', NULL),
  ('natalya.frolova@mail.ru', 'Варвара', 'Силуэт', '2026-01-12', NULL),
  ('kseniya.stepanova@mail.ru', 'Арина', 'Силуэт', '2026-09-01', NULL),
  ('olga.zhukova@mail.ru', 'Вероника', 'Гармония', '2025-09-01', NULL),
  ('vera.grigoreva@mail.ru', 'Алиса', 'Гармония', '2025-09-01', NULL),
  ('nadezhda.fedorova@mail.ru', 'Елизавета', 'Гармония', '2025-09-01', NULL),
  ('natalya.frolova@mail.ru', 'Яна', 'Гармония', '2025-09-01', NULL),
  ('evgeniya.ilina@mail.ru', 'Полина', 'Гармония', '2026-01-12', NULL),
  ('pavel.maksimov@mail.ru', 'Злата', 'Гармония', '2026-01-12', NULL),
  ('ekaterina.kovaleva@mail.ru', 'Злата', 'Гармония', '2025-09-01', NULL),
  ('yuliya.dmitrieva@mail.ru', 'Ева', 'Гармония', '2026-01-12', NULL),
  ('tatyana.nikolaeva@mail.ru', 'Варвара', 'Гармония', '2026-09-01', NULL),
  ('irina.smirnova@mail.ru', 'Варвара', 'Гармония', '2026-09-01', NULL),
  ('pavel.maksimov@mail.ru', 'Варвара', 'Гармония', '2025-09-01', NULL),
  ('tatyana.nikitina@mail.ru', 'Полина', 'Гармония', '2025-09-01', NULL),
  ('yuliya.belyaeva@mail.ru', 'Таисия', 'Гармония', '2025-09-01', NULL),
  ('artem.aleksandrov@mail.ru', 'Виктория', 'Гармония', '2025-09-01', NULL),
  ('kseniya.antonova@mail.ru', 'Диана', 'Пластика', '2026-09-01', NULL),
  ('aleksandra.borisova@mail.ru', 'Алёна', 'Пластика', '2026-09-01', NULL),
  ('ivan.komarov@mail.ru', 'Елизавета', 'Пластика', '2026-09-01', NULL),
  ('dmitriy.zaytsev@mail.ru', 'Мирослава', 'Пластика', '2026-09-01', NULL),
  ('olga.filippova@mail.ru', 'Вероника', 'Пластика', '2026-09-01', NULL),
  ('mikhail.vorobev@mail.ru', 'Таисия', 'Пластика', '2026-09-01', NULL),
  ('svetlana.mikhaylova@mail.ru', 'Валерия', 'Пластика', '2026-09-01', NULL),
  ('svetlana.guseva@mail.ru', 'Таисия', 'Пластика', '2026-09-01', NULL),
  ('kseniya.antonova@mail.ru', 'Яна', 'Жемчужинки', '2025-09-01', NULL),
  ('alena.baranova@mail.ru', 'Алиса', 'Жемчужинки', '2025-09-01', NULL),
  ('mariya.alekseeva@mail.ru', 'Елизавета', 'Жемчужинки', '2026-09-01', NULL),
  ('yuliya.kiseleva@mail.ru', 'Злата', 'Жемчужинки', '2026-01-12', NULL),
  ('polina.pavlova@mail.ru', 'Вероника', 'Жемчужинки', '2026-01-12', NULL),
  ('artem.novikov@mail.ru', 'Ева', 'Жемчужинки', '2026-09-01', NULL),
  ('natalya.lebedeva@mail.ru', 'Алёна', 'Жемчужинки', '2026-09-01', NULL),
  ('pavel.tarasov@mail.ru', 'Кира', 'Жемчужинки', '2025-09-01', NULL),
  ('olga.filippova@mail.ru', 'Дарья', 'Жемчужинки', '2026-09-01', NULL),
  ('nadezhda.fedorova@mail.ru', 'Диана', 'Грация', '2026-09-01', NULL),
  ('natalya.egorova@mail.ru', 'Агата', 'Грация', '2026-01-12', NULL),
  ('nadezhda.yakovleva@mail.ru', 'Василиса', 'Грация', '2025-09-01', NULL),
  ('artem.aleksandrov@mail.ru', 'Елизавета', 'Грация', '2025-09-01', NULL),
  ('ekaterina.bogdanova@mail.ru', 'Мария', 'Грация', '2025-09-01', NULL),
  ('kseniya.antonova@mail.ru', 'Варвара', 'Грация', '2025-09-01', NULL),
  ('olga.ivanova@mail.ru', 'Кира', 'Грация', '2025-09-01', NULL),
  ('aleksandra.vinogradova@mail.ru', 'Николь', 'Грация', '2026-01-12', NULL),
  ('svetlana.kuzmina@mail.ru', 'Василиса', 'Грация', '2026-09-01', NULL),
  ('mariya.alekseeva@mail.ru', 'Ангелина', 'Сальто', '2026-09-01', NULL),
  ('polina.gerasimova@mail.ru', 'Иван', 'Сальто', '2026-09-01', NULL),
  ('irina.smirnova@mail.ru', 'Виктория', 'Сальто', '2025-09-01', NULL),
  ('natalya.polyakova@mail.ru', 'Дарья', 'Сальто', '2026-01-12', NULL),
  ('marina.makarova@mail.ru', 'Мирон', 'Сальто', '2025-09-01', NULL),
  ('darya.popova@mail.ru', 'Вероника', 'Сальто', '2026-09-01', NULL),
  ('evgeniya.volkova@mail.ru', 'Кирилл', 'Сальто', '2025-09-01', NULL),
  ('irina.sidorova@mail.ru', 'Максим', 'Сальто', '2025-09-01', NULL),
  ('olga.petrova@mail.ru', 'Василиса', 'Сальто', '2025-09-01', NULL),
  ('ekaterina.sokolova@mail.ru', 'Максим', 'Сальто', '2025-09-01', NULL),
  ('alena.sorokina@mail.ru', 'Василиса', 'Сальто', '2026-09-01', NULL),
  ('mikhail.kuznetsov@mail.ru', 'Михаил', 'Пирамида', '2026-09-01', NULL),
  ('yuliya.semenova@mail.ru', 'Дарья', 'Пирамида', '2025-09-01', NULL),
  ('alena.zakharova@mail.ru', 'Максим', 'Пирамида', '2026-09-01', NULL),
  ('elena.kozlova@mail.ru', 'Кира', 'Пирамида', '2026-01-12', NULL),
  ('aleksey.korolev@mail.ru', 'Арсений', 'Пирамида', '2025-09-01', NULL),
  ('evgeniya.romanova@mail.ru', 'Агата', 'Пирамида', '2026-01-12', NULL),
  ('vera.osipova@mail.ru', 'Николь', 'Пирамида', '2025-09-01', NULL),
  ('ekaterina.orlova@mail.ru', 'Тимофей', 'Пирамида', '2025-09-01', NULL),
  ('tatyana.morozova@mail.ru', 'Арина', 'Пирамида', '2025-09-01', NULL),
  ('aleksandra.soloveva@mail.ru', 'Вероника', 'Атлет', '2026-09-01', NULL),
  ('ivan.komarov@mail.ru', 'Василиса', 'Атлет', '2026-09-01', NULL),
  ('viktoriya.davydova@mail.ru', 'Мария', 'Атлет', '2026-09-01', NULL),
  ('vera.osipova@mail.ru', 'Стефания', 'Атлет', '2026-09-01', NULL),
  ('nikolay.lebedev@mail.ru', 'Стефания', 'Атлет', '2026-09-01', NULL),
  ('evgeniya.volkova@mail.ru', 'Варвара', 'Атлет', '2026-09-01', NULL),
  ('pavel.bogdanov@mail.ru', 'Виктория', 'Атлет', '2026-09-01', NULL),
  ('ivan.grigorev@mail.ru', 'Ульяна', 'Атлет', '2026-09-01', NULL),
  ('artem.popov@mail.ru', 'Злата', 'Атлет', '2026-09-01', NULL),
  ('olga.kuzmina@mail.ru', 'Ева', 'Атлет', '2026-09-01', NULL),
  ('aleksandra.maksimova@mail.ru', 'Мирон', 'Атлет', '2026-09-01', NULL),
  ('yuliya.morozova@mail.ru', 'Стефания', 'Сила', '2026-09-01', NULL),
  ('aleksandra.romanova@mail.ru', 'Иван', 'Сила', '2025-09-01', NULL),
  ('olga.yakovleva@mail.ru', 'Кира', 'Сила', '2025-09-01', NULL),
  ('aleksandra.belova@mail.ru', 'Полина', 'Сила', '2026-01-12', NULL),
  ('alena.makarova@mail.ru', 'Роман', 'Сила', '2025-09-01', NULL),
  ('olga.grigoreva@mail.ru', 'Марк', 'Сила', '2025-09-01', NULL),
  ('kseniya.morozova@mail.ru', 'Елизавета', 'Сила', '2025-09-01', NULL),
  ('aleksandra.kuznetsova@mail.ru', 'Артём', 'Сила', '2026-09-01', NULL),
  ('ekaterina.kozlova@mail.ru', 'Ева', 'Сила', '2025-09-01', NULL),
  ('mariya.frolova@mail.ru', 'Злата', 'Сила', '2025-09-01', NULL),
  ('elena.kozlova@mail.ru', 'Дарья', 'Гибкость', '2025-09-01', NULL),
  ('svetlana.kiseleva@mail.ru', 'Есения', 'Гибкость', '2026-09-01', NULL),
  ('elena.maksimova@mail.ru', 'Яна', 'Гибкость', '2026-01-12', NULL),
  ('marina.fedorova@mail.ru', 'София', 'Гибкость', '2026-01-12', NULL),
  ('artem.popov@mail.ru', 'Елизавета', 'Гибкость', '2026-09-01', NULL),
  ('polina.makarova@mail.ru', 'Есения', 'Гибкость', '2025-09-01', NULL),
  ('polina.guseva@mail.ru', 'Василиса', 'Гибкость', '2025-09-01', NULL),
  ('evgeniya.koroleva@mail.ru', 'Варвара', 'Гибкость', '2025-09-01', NULL),
  ('aleksandra.romanova@mail.ru', 'Вероника', 'Шпагат', '2026-01-12', NULL),
  ('ekaterina.smirnova@mail.ru', 'Злата', 'Шпагат', '2025-09-01', NULL),
  ('polina.gerasimova@mail.ru', 'Николь', 'Шпагат', '2025-09-01', NULL),
  ('aleksandra.kozlova@mail.ru', 'Стефания', 'Шпагат', '2026-01-12', NULL),
  ('tatyana.belyaeva@mail.ru', 'Анна', 'Шпагат', '2026-09-01', NULL),
  ('andrey.antonov@mail.ru', 'Мария', 'Шпагат', '2026-01-12', NULL),
  ('natalya.polyakova@mail.ru', 'Анна', 'Шпагат', '2026-09-01', NULL),
  ('mikhail.frolov@mail.ru', 'Кира', 'Шпагат', '2026-09-01', NULL),
  ('tatyana.filippova@mail.ru', 'Есения', 'Па-де-де', '2026-01-12', NULL),
  ('mariya.kiseleva@mail.ru', 'Яна', 'Па-де-де', '2026-01-12', NULL),
  ('nadezhda.vinogradova@mail.ru', 'Яна', 'Па-де-де', '2026-09-01', NULL),
  ('viktoriya.kuzmina@mail.ru', 'Алёна', 'Па-де-де', '2025-09-01', NULL),
  ('anna.zakharova@mail.ru', 'Ксения', 'Па-де-де', '2026-01-12', NULL),
  ('alena.filippova@mail.ru', 'Варвара', 'Па-де-де', '2025-09-01', NULL),
  ('kseniya.mikhaylova@mail.ru', 'Мария', 'Па-де-де', '2026-09-01', NULL),
  ('elena.ivanova@mail.ru', 'Агата', 'Па-де-де', '2026-01-12', NULL),
  ('pavel.maksimov@mail.ru', 'Диана', 'Па-де-де', '2026-01-12', NULL),
  ('kseniya.volkova@mail.ru', 'Диана', 'Па-де-де', '2026-01-12', NULL),
  ('aleksandra.novikova@mail.ru', 'Алиса', 'Па-де-де', '2026-01-12', NULL),
  ('pavel.maksimov@mail.ru', 'Варвара', 'Шпагат', '2026-09-01', NULL),
  ('evgeniya.ilina@mail.ru', 'Полина', 'Шпагат', '2026-09-01', NULL),
  ('dmitriy.zaytsev@mail.ru', 'Мирослава', 'Гибкость', '2026-09-01', NULL),
  ('ivan.komarov@mail.ru', 'Елизавета', 'Гибкость', '2026-09-01', NULL),
  ('kseniya.stepanova@mail.ru', 'Арина', 'Па-де-де', '2026-09-01', NULL),
  ('evgeniya.ilina@mail.ru', 'Алёна', 'Па-де-де', '2026-09-01', NULL),
  ('irina.sidorova@mail.ru', 'Максим', 'Сила', '2026-09-01', NULL),
  ('darya.popova@mail.ru', 'Вероника', 'Сила', '2026-09-01', NULL),
  ('artem.aleksandrov@mail.ru', 'Виктория', 'Па-де-де', '2026-09-01', NULL),
  ('olga.zhukova@mail.ru', 'Вероника', 'Па-де-де', '2026-09-01', NULL),
  ('anna.belyaeva@mail.ru', 'Стефания', 'Гармония', '2025-09-01', '2026-05-25'),
  ('dmitriy.osipov@mail.ru', 'Егор', 'Сальто', '2025-09-01', '2026-05-25'),
  ('kseniya.zakharova@mail.ru', 'Тимофей', 'Сила', '2025-09-01', '2026-05-25'),
  ('darya.ivanova@mail.ru', 'Ульяна', 'Шпагат', '2025-09-01', '2026-05-25'),
  ('vera.soloveva@mail.ru', 'Василиса', 'Атлет', '2026-09-01', '2026-10-01'),
  ('evgeniya.ilina@mail.ru', 'Валерия', 'Силуэт', '2025-09-01', '2026-03-02'),
  ('evgeniya.ilina@mail.ru', 'Валерия', 'Силуэт', '2026-09-01', NULL),
  ('ekaterina.borisova@mail.ru', 'Алиса', 'Балет', '2025-09-01', '2026-06-01'),
  ('mariya.vasileva@mail.ru', 'Варвара', 'Балет', '2025-09-01', '2026-06-01'),
  ('alena.sorokina2@mail.ru', 'Варвара', 'Балет', '2025-09-01', '2026-06-01'),
  ('olga.belyaeva@mail.ru', 'Алиса', 'Балет', '2025-09-01', '2026-06-01'),
  ('nadezhda.novikova@mail.ru', 'Мирослава', 'Балет', '2025-09-01', '2026-06-01'),
  ('aleksandra.sorokina@mail.ru', 'Полина', 'Балет', '2025-09-01', '2026-06-01'),
  ('artem.ilin@mail.ru', 'Злата', 'Балет', '2025-09-01', '2026-06-01')
) AS v(parent_mail, first, grp, d_from, d_to)
JOIN account a ON lower(a.mail) = lower(v.parent_mail)
JOIN student s ON s.parent_id = a.id AND s.first_name = v.first
JOIN training_group g ON g.name = v.grp;

-- ============ Расписание: недельный шаблон
-- Составлено вручную генератором демо-данных и проверено на Ж1–Ж9. Алгоритм диплома будет строить своё.
INSERT INTO assignment (group_trainer_id, room_id, slot_id)
SELECT gt.id, r.id, s.id
FROM (VALUES
  ('Жемчужинки', 1, '15:30', 'Большой ковровый'),
  ('Силуэт', 1, '17:00', 'Большой ковровый'),
  ('Пирамида', 1, '18:30', 'Акробатический'),
  ('Сила', 1, '20:00', 'Акробатический'),
  ('Гармония', 1, '20:00', 'Большой ковровый'),
  ('Силуэт', 2, '15:30', 'Большой ковровый'),
  ('Сила', 2, '17:00', 'Акробатический'),
  ('Гармония', 2, '17:00', 'Большой ковровый'),
  ('Грация', 2, '18:30', 'Большой ковровый'),
  ('Шпагат', 2, '20:00', 'Акробатический'),
  ('Сальто', 3, '15:30', 'Акробатический'),
  ('Силуэт', 3, '15:30', 'Большой ковровый'),
  ('Гибкость', 3, '15:30', 'Малый'),
  ('Грация', 3, '17:00', 'Большой ковровый'),
  ('Жемчужинки', 3, '18:30', 'Большой ковровый'),
  ('Па-де-де', 3, '18:30', 'Хореографический'),
  ('Шпагат', 3, '20:00', 'Большой ковровый'),
  ('Грация', 4, '15:30', 'Большой ковровый'),
  ('Гибкость', 4, '15:30', 'Хореографический'),
  ('Пирамида', 4, '17:00', 'Акробатический'),
  ('Пластика', 4, '17:00', 'Большой ковровый'),
  ('Па-де-де', 4, '17:00', 'Хореографический'),
  ('Сила', 4, '18:30', 'Большой ковровый'),
  ('Шпагат', 4, '20:00', 'Большой ковровый'),
  ('Силуэт', 5, '15:30', 'Большой ковровый'),
  ('Пластика', 5, '17:00', 'Большой ковровый'),
  ('Сальто', 5, '18:30', 'Акробатический'),
  ('Атлет', 5, '18:30', 'Большой ковровый'),
  ('Пирамида', 5, '20:00', 'Акробатический'),
  ('Пирамида', 6, '09:30', 'Акробатический'),
  ('Атлет', 6, '11:00', 'Акробатический'),
  ('Гармония', 6, '11:00', 'Большой ковровый'),
  ('Грация', 6, '12:30', 'Большой ковровый'),
  ('Па-де-де', 6, '12:30', 'Хореографический'),
  ('Сальто', 6, '14:00', 'Акробатический')
) AS v(grp, dow, t, room)
JOIN training_group g ON g.name = v.grp
JOIN group_trainer gt ON gt.training_group_id = g.id AND gt.end_date IS NULL
JOIN room r ON r.name = v.room
JOIN slot s ON s.day_of_week = v.dow AND s.start_time = v.t::time;

-- ============ Занятия на даты
-- Из шаблона: каждое назначение повторяется в свой день недели с 07.09 по 17.10.2026.
-- До 12.10 — «проведено», с 12.10 — «запланировано».
INSERT INTO lesson (assignment_id, lesson_status_id, lesson_date, slot_id, room_id)
SELECT asg.id,
       ls.id,
       d::date,
       asg.slot_id,
       asg.room_id
FROM assignment asg
JOIN slot s ON s.id = asg.slot_id
JOIN generate_series(date '2026-09-07', date '2026-10-17', interval '1 day') AS d
  ON extract(isodow FROM d) = s.day_of_week
JOIN lesson_status ls
  ON ls.name = CASE WHEN d < date '2026-10-12' THEN 'проведено' ELSE 'запланировано' END
ORDER BY d, s.start_time;

-- Отмены: статус «отменено», причина текстом (решение 18).
UPDATE lesson SET lesson_status_id = (SELECT id FROM lesson_status WHERE name = 'отменено'), comment = 'Болезнь тренера, замены нет'
WHERE lesson_date = date '2026-09-10' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 4 AND s.start_time = time '17:00');
UPDATE lesson SET lesson_status_id = (SELECT id FROM lesson_status WHERE name = 'отменено'), comment = 'Тренер на соревнованиях с командой'
WHERE lesson_date = date '2026-10-08' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 4 AND s.start_time = time '15:30');
UPDATE lesson SET lesson_status_id = (SELECT id FROM lesson_status WHERE name = 'отменено'), comment = 'Ремонт вентиляции в зале'
WHERE lesson_date = date '2026-10-05' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 1 AND s.start_time = time '15:30');
UPDATE lesson SET lesson_status_id = (SELECT id FROM lesson_status WHERE name = 'отменено'), comment = 'Тренер на соревнованиях с командой'
WHERE lesson_date = date '2026-09-08' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 2 AND s.start_time = time '17:00');

-- Переносы: меняются фактические дата, пара или зал; шаблон не трогается. Новое место проверено на конфликты.
UPDATE lesson SET lesson_date = date '2026-09-10',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 4 AND start_time = time '15:30'),
  room_id = (SELECT id FROM room WHERE name = 'Малый'),
  comment = 'Зал занят под соревнования'
WHERE lesson_date = date '2026-09-10' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 4 AND s.start_time = time '15:30');
UPDATE lesson SET lesson_date = date '2026-10-10',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 6 AND start_time = time '09:30'),
  room_id = (SELECT id FROM room WHERE name = 'Большой ковровый'),
  comment = 'Протечка в зале'
WHERE lesson_date = date '2026-10-10' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Большой ковровый' AND s.day_of_week = 6 AND s.start_time = time '11:00');
UPDATE lesson SET lesson_date = date '2026-09-08',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 2 AND start_time = time '18:30'),
  room_id = (SELECT id FROM room WHERE name = 'Акробатический'),
  comment = 'Перенос по просьбе родителей перед праздником'
WHERE lesson_date = date '2026-09-08' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Акробатический' AND s.day_of_week = 2 AND s.start_time = time '17:00');
UPDATE lesson SET lesson_date = date '2026-09-11',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 5 AND start_time = time '18:30'),
  room_id = (SELECT id FROM room WHERE name = 'Хореографический'),
  comment = 'Зал занят под соревнования'
WHERE lesson_date = date '2026-09-09' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Хореографический' AND s.day_of_week = 3 AND s.start_time = time '18:30');
UPDATE lesson SET lesson_date = date '2026-10-10',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 6 AND start_time = time '12:30'),
  room_id = (SELECT id FROM room WHERE name = 'Акробатический'),
  comment = 'Зал занят под соревнования'
WHERE lesson_date = date '2026-10-10' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Акробатический' AND s.day_of_week = 6 AND s.start_time = time '14:00');
UPDATE lesson SET lesson_date = date '2026-09-29',
  slot_id = (SELECT id FROM slot WHERE day_of_week = 2 AND start_time = time '15:30'),
  room_id = (SELECT id FROM room WHERE name = 'Акробатический'),
  comment = 'Перенос по просьбе родителей перед праздником'
WHERE lesson_date = date '2026-09-29' AND assignment_id = (
  SELECT asg.id FROM assignment asg JOIN room r ON r.id = asg.room_id JOIN slot s ON s.id = asg.slot_id
  WHERE r.name = 'Акробатический' AND s.day_of_week = 2 AND s.start_time = time '17:00');

-- ============ Посещаемость
-- Отметки только на проведённых занятиях и только у тех, кто состоял в группе в день занятия:
-- start_date <= дата И (end_date пустая ИЛИ end_date > дата) — полуоткрытый период (решение 19).
-- Статус псевдослучайный, но воспроизводимый: первый байт md5 от пары «занятие:ученик».
-- Примерно 86% присутствовал, 9% отсутствовал, 5% опоздал.
INSERT INTO attendance (lesson_id, student_id, attendance_status_id)
SELECT l.id, sg.student_id, ats.id
FROM lesson l
JOIN lesson_status ls ON ls.id = l.lesson_status_id AND ls.name = 'проведено'
JOIN assignment asg   ON asg.id = l.assignment_id
JOIN group_trainer gt ON gt.id = asg.group_trainer_id
JOIN student_group sg ON sg.training_group_id = gt.training_group_id
                     AND sg.start_date <= l.lesson_date
                     AND (sg.end_date IS NULL OR sg.end_date > l.lesson_date)
CROSS JOIN LATERAL (SELECT get_byte(decode(md5(l.id || ':' || sg.student_id), 'hex'), 0) * 100 / 256 AS roll) x
JOIN attendance_status ats ON ats.name = CASE
       WHEN x.roll < 86 THEN 'присутствовал'
       WHEN x.roll < 95 THEN 'отсутствовал'
       ELSE 'опоздал' END;

COMMIT;