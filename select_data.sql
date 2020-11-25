USE telegram;

-- Выборка данных пользователя по id
SELECT firstname, lastname, login, phone, gender, birthday, country
FROM users
JOIN profiles ON users.id = profiles.user_id
WHERE users.id = 1;

-- Количество каналов у пользователей
SELECT login, count(*) AS total_channels
FROM users
JOIN users_channels ON users.id = users_channels.user_id
GROUP BY users.id
ORDER BY count(*) desc;

-- Среднее количество каналов у всех пользователей    
SELECT AVG(total_channels) AS average_channels
FROM (
	SELECT login, count(*) AS total_channels
	FROM users
	JOIN users_channels ON users.id = users_channels.user_id
	GROUP BY users.id
) AS list;

-- Количество пользователей в каналах
SELECT count(*), c.channels_name
FROM telegram.users_channels uc
JOIN channels c on uc.channels_id = c.id
GROUP BY c.id;

-- Сообщения к пользователю
SELECT messages.messages_body, login, messages.created_at
FROM messages
JOIN users ON users.id = messages.to_user_id
WHERE users.id = 1;
  
-- Сообщения от пользователя
SELECT messages.messages_body, login, created_at
FROM messages
JOIN users ON users.id = messages.from_user_id
WHERE users.id = 1;

-- Представление сообщений: u1 - отправитель, u2 - получатель
CREATE OR REPLACE VIEW `user_messages` AS
SELECT 
	u1.login as 'sender',
	u2.login as 'receiver',
	m.*
FROM users u1
JOIN messages m ON u1.id = m.from_user_id 
JOIN users u2 ON u2.id = m.to_user_id 
WHERE u1.id = 1;

SELECT
	sender,
	receiver,
	messages_body,
	created_at
FROM user_messages;

-- Представление звонков: u1 - звонящий, u2 - принимающий
CREATE OR REPLACE VIEW `user_calls` AS
SELECT 
	u1.login as 'caller',
	u2.contacts_name as 'receiver',
	c.*
FROM users u1
JOIN calls c ON u1.id = c.from_user_id 
JOIN user_contacts u2 ON u2.id = c.to_user_id 
WHERE u1.id = 1;

SELECT
	caller,
	receiver,
	creared_at
FROM user_calls;

-- Выборка новостей пользователя
SELECT media.file_name, media.media_body, users.login 
FROM media
JOIN users_channels uc ON media.channels_id = uc.channels_id
JOIN users ON uc.user_id = users.id
WHERE users.id = 1
ORDER BY created_at desc;

-- Добавление нового пользователя
DROP PROCEDURE IF EXISTS telegram.sp_add_user;

DELIMITER $$
$$
CREATE PROCEDURE telegram.sp_add_user(
	firstname varchar(50),
	lastname varchar(50),
	login varchar(50),
	phone bigint UNSIGNED,
	password_hash varchar(100),
	gender char(1),
	birthday date,
	country varchar(50),
	image_id bigint UNSIGNED,
	OUT tran_result varchar(200)
)
BEGIN
	DECLARE `_rollback` bit DEFAULT 0;
	DECLARE code varchar(100);
	DECLARE error_string varchar(100);
	
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
		SET `_rollback` = 1;
		
		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
		
		SET tran_result = concat('Error occured. ', code, ' ', error_string);
	END;

	START TRANSACTION;
		INSERT INTO users (firstname, lastname, login, phone, password_hash)
		VALUES (firstname, lastname, login, phone, password_hash);
	
		INSERT INTO profiles (user_id, gender, birthday, country, image_id)
		VALUES (last_insert_id(), gender, birthday, country, image_id);
	
	IF `_rollback` = 1 THEN
		ROLLBACK;
	ELSE 
		SET tran_result = 'ok';
		COMMIT;
	END IF;
END

$$
DELIMITER ;

CALL sp_add_user('New2firstname', 'New2lastname', 'new2login', '89999999999', 'new2password_hash', 'm', '1984-08-04', 'Newcountry', '52', @tran_result);
SELECT @tran_result;
SELECT * FROM users ORDER BY id DESC;
SELECT * FROM profiles ORDER BY user_id DESC;