create database ExamenMicro;
use ExamenMicro;

Create table AutorLibro(
AutorLibroId int identity(1,1),
Nombre nvarchar,
Apellido nvarchar,
FechaNacimiento Datetime,

constraint AutorLibroId 
primary key (AutorLibroId)
);

create table GradoAcademico(
GradoAcademicoId int identity(1,1),
Nombre nvarchar,
CentroAcademico nvarchar,
FechaGado Datetime,
AutorLibroId int,
constraint GradoAcademicoId
primary key (GradoAcademicoId),
constraint AutorLibroId_fk
foreign key(AutorLibroId)
references AutorLibro(AutorLibroId)
);
USE ExamenMicro;
EXEC sp_rename 'GradoAcademico.FechaGado', 'FechaGrado', 'COLUMN';
ALTER TABLE AutorLibro ADD AutorLibroGuid NVARCHAR(50);
ALTER TABLE GradoAcademico ADD GradoAcademicoGuid NVARCHAR(50);

ALTER TABLE AutorLibro ALTER COLUMN Nombre NVARCHAR(100);
ALTER TABLE AutorLibro ALTER COLUMN Apellido NVARCHAR(100);

-- Modifica las columnas en 'GradoAcademico' para evitar errores similares
ALTER TABLE GradoAcademico ALTER COLUMN Nombre NVARCHAR(100);
ALTER TABLE GradoAcademico ALTER COLUMN CentroAcademico NVARCHAR(100);

INSERT INTO AutorLibro (Nombre, Apellido, FechaNacimiento) 
VALUES ('Juan', 'Pérez', '1985-06-15');

INSERT INTO GradoAcademico (Nombre, CentroAcademico, FechaGrado, AutorLibroId) 
VALUES ('Maestría en TI', 'Universidad Nacional', '2015-07-20',3);

SELECT * FROM AutorLibro;
