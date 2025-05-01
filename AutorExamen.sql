use AutorExamen


-- Eliminar la tabla existente
DROP TABLE IF EXISTS dbo.LibreriaMaterial;
GO

-- Crear la tabla con la columna LibreriaMaterialId como INT y AutorLibro como NVARCHAR
CREATE TABLE dbo.LibreriaMaterial (
    LibreriaMaterialId INT IDENTITY(1,1) PRIMARY KEY,
    Titulo NVARCHAR(255) NOT NULL,
    FechaPublicacion DATE NULL,
    AutorLibro NVARCHAR(255) NULL
);
GO
select * from dbo.LibreriaMaterial
select * from AutorLibros
