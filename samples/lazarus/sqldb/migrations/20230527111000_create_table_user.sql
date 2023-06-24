-- +duck Up
CREATE TABLE users (name varchar(10) NOT NULL);
-- +duck Down
DROP TABLE users;
