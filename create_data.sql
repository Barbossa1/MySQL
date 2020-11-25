DROP DATABASE IF EXISTS telegram;
CREATE DATABASE telegram;
USE telegram;

-- Пользователи
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(50),
    lastname VARCHAR(50),
    login VARCHAR(50),
    phone BIGINT UNSIGNED UNIQUE,
 	password_hash VARCHAR(100), 
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

-- Контакты пользователей
DROP TABLE IF EXISTS user_contacts;
CREATE TABLE user_contacts (
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
	contacts_name VARCHAR(50),
	phone BIGINT UNSIGNED UNIQUE,
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (phone) REFERENCES users(phone)
);

-- Сообщения между пользователями
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    messages_body TEXT,
    created_at TIMESTAMP DEFAULT NOW(),

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

-- Звонки между пользователями
DROP TABLE IF EXISTS calls;
CREATE TABLE calls (
	id SERIAL,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	creared_at TIMESTAMP DEFAULT NOW(),
	
	FOREIGN KEY (from_user_id) REFERENCES users(id),
	FOREIGN KEY (to_user_id) REFERENCES user_contacts(id)
);

-- Телеграм каналы
DROP TABLE IF EXISTS channels;
CREATE TABLE channels (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	channels_name VARCHAR(50),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	
	INDEX channels_name_idx(channels_name),
	FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

-- Пользователи в каналах
DROP TABLE IF EXISTS users_channels;
CREATE TABLE users_channels (
	user_id BIGINT UNSIGNED NOT NULL,
	channels_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, channels_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (channels_id) REFERENCES channels(id)
);

-- Типы медиа данных
DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id SERIAL,
    types_name ENUM('img', 'vid', 'mus') NOT NULL
);

-- Сами медиa данные
DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL,
	file_name VARCHAR(50),
    media_type_id BIGINT UNSIGNED NOT NULL,
    media_body TEXT,
    size INT,
    channels_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (channels_id) REFERENCES channels(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

-- Изображения img
DROP TABLE IF EXISTS image;
CREATE TABLE image (
	id SERIAL,
	image_name VARCHAR(50) DEFAULT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Видео vid
DROP TABLE IF EXISTS video;
CREATE TABLE video (
	id SERIAL,
	video_name VARCHAR(50) DEFAULT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Музыка mus
DROP TABLE IF EXISTS music;
CREATE TABLE music (
	id SERIAL,
	music_name VARCHAR(50) DEFAULT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED DEFAULT NULL,

    FOREIGN KEY (media_id) REFERENCES media(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Профили пользователей
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
    country VARCHAR(50), 
	image_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT NOW(),
	
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (image_id) REFERENCES media(id)
);