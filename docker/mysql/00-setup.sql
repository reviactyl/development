create database if not exists testing;

grant all on testing.* TO 'reviactyl'@'%';
grant all on `testing\_test_%`.* TO 'reviactyl'@'%';

flush privileges;