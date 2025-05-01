-- crear login (acceso al servidor) de SQL
--Este login da acceso al servidor

use master 
go

-- Login con autenticacion SQL
create login DevelopmentUser with password='12345678';

-- Crear login con autenticacion de windows
-- create user 'cookie\serveerbd' for windows; servidor\nombreServidor

-- Crear un usuario asociado al login y base de datos
use AdventureWorks2022
create user DevelopmentUser for login DevelopmentUser
with default_schema=informatica
go
create schema informatica 
authorization DevelopmentUser
go
--Permisos de manera individual 
Grant create table to DevelopmentUser ;
Grant select,insert, delete to DevelopmentUser;

-- deny, deniega/elimina el permiso

deny delete to DevelopmentUser

-- revoke elimina completamente
--permisos por tabla
grant select on Person.person to DevelopmentUser;
grant select(FirstName) on Person.person to DevelopmentUser;


--Le da permisos de lectura a todo
exec sp_addrolemember
'db_datareader', DevelopmentUser
drop user DevelopmentUser;


-- comandos con DevelopmentUser
use AdventureWorks2022

select * from AdventureWorks2022;

create table informatica.xyz(
id_xyz int identity(1,1),
nombre varchar
)

insert into informatica.xyz
values('cosa1');
select*from Person.person;

select PersonType from Person.person;





