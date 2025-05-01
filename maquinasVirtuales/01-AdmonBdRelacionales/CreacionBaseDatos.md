# Creacion de base de datos

```sql

create database paquitabd2
on primary --filegroup
(
Name = paquitabdData, filename='C:\Users\admonbd\Documents\NuevaData\paquitabd.mdf', --Nombre filegroup, filename donde se encuentra la careta donde se guardara
size = 50MB, --tamano de la bd, el tamano minimoes de 512kb y el predeterminado es 1MB
filegrowth = 25%, --es el crecimiento a partir del tamano, es lo que se va a reservar y el default es el 10%
maxsize = 400MB --cuando ya llega a los 400, la bd estara en un estado de solo lectura
)
log on
(
Name = paquitabdLog, filename = 'C:\Users\admonbd\Documents\NuevoLog\paquitabd_Log.ldf',
size= 25MB,
filegrowth = 25%
)

--crear un archivo adicional

alter database paquitabd2

ADD FILE 
(
Name = 'paquitaDataNDF',
filename = 'C:\Users\admonbd\Documents\NuevaData\paquitabd2.ndf',
size = 25MB,
maxsize=500MB,
filegrowth = 10MB
) TO FILEGROUP[PRIMARY];

-- creacion de un file group adicional
alter DATABASE paquitabd2
ADD FILEGROUP SECUNDARIO
GO

--crear un archivo asociado al filegroup secundario
alter database paquitabd2
ADD file
(
Name = 'paquitabdParte1', filename='C:\Users\admonbd\Documents\NuevaData\paquitabd_SECUNDARIO.ndf'
)TO FILEGROUP SECUNDARIO

--crear una tabla en el group file secundario
use paquitabd2
create table RataDeDosPatas
(
id int not null identity(1,1),
nombre nvarchar(100) not null,
constraint pk_RataDeDosPatas
primary key(id),
constraint unico_nombre
unique(nombre)

)ON SECUNDARIO; --especificamos el filegroup

--modificar el groupfile primario
use master 
alter database paquitabd2
MODIFY  FILEGROUP [SECUNDARIO] DEFAULT
--ahora esta tabla se guardara por default en el secundario, por la consulta anterior
use paquitabd2
create table ComparadoContigo(
id int not null identity(1,1),
nombre_Animal nvarchar(100) not null,
defectos nvarchar (max) not null
constraint pk_ComparadoContigo
primary key(id),
constraint unico_nombre3
unique(nombre_Animal))

--revision del estado de la opcion de ajuste automatico de tamano de archivos
--sirve para administrar el espacio en automatico
select DATABASEPROPERTYEX('paquitabd2', 'ISAUTOSHRINK') --el shrink es para quitar el espacio, desfragmentarlo, espacios vacios
-- cambia a true y le da por default un espacio
alter database paquitabd2 
SET AUTO_SHRINK ON WITH NO_WAIT
go

--revision del estado de la opcion  de creacion de estadisticas
SELECT DATABASEPROPERTYEX('paquitabd2', 'IsAutoCreateStatistics')
--para desactivar las estadisticas
ALTER DATABASE paquitabd2
SET AUTO_CREATE_STATISTICS OFF
go
--para prenderlas
ALTER DATABASE paquitabd2
SET AUTO_CREATE_STATISTICS ON
go

--consultar info de la bd
--todo SP es una store procedure de sql, se debe de susar master
use master
go
SP_helpdb paquitabd2

--consultar la info de filegroups
go 
use paquitabd2
go
SP_HELPFILEGROUP SECUNDARIO


```