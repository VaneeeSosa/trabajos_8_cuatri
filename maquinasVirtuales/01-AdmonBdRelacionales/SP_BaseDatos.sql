-- SP ESTATICO --

CREATE PROCEDURE sp_CrearBaseDatosEstatica
AS
BEGIN;

-- usar el if para saber si existe una base de datos llamada igual 
    IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MiBD_Procedure')
    BEGIN
        CREATE DATABASE MiBaseDatos_Con_Procedure
        ON PRIMARY 
        ( 
		-- Recuerda, esto ya lo viste en clase
            NAME = 'MiBaseDatos_Con_Procedure_MDF',
            FILENAME = '/var/opt/mssqlMiBaseDatos_Con_Procedure.mdf', -- essa ruta porque ahi se guarda en el docker
            SIZE = 10MB,
            FILEGROWTH = 5MB
        )
        LOG ON 
        ( 
            NAME = 'MiBaseDatos_Con_Procedure_LDF',
            FILENAME = '/var/opt/mssql/MiBaseDatos_Con_Procedure.ldf', 
            SIZE = 5MB,
            FILEGROWTH = 2MB
        );
		-- se usa print para mandar el msj de que se ha creado o si ya existe
        PRINT 'Base de datos creada exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'La base de datos ya existe.';
    END
END;

go


-- SP DINAMICO --

CREATE PROCEDURE sp_CrearBaseDatos 

-- Variables para el programa, El @ solo se usa para identificar las variables y es necesario para poder usarlas
    @NombreDB NVARCHAR(100),
    @RutaMDF NVARCHAR(255),
    @TamanoInicialMDF INT,  
    @CrecimientoMDF INT,     
    @RutaLDF NVARCHAR(255),
    @TamanoInicialLDF INT,   
    @CrecimientoLDF INT    
AS
BEGIN;

   -- DECLARE sirve para declarar una variable, esta se usara para almacenar una consulta
   -- Es obligatorio para declarar variables, tmb se usa solo dentro del bloque Begin...End
    DECLARE @SQL NVARCHAR(MAX);

	-- aqui se usa la variable para la instruccion o cosa que va a hacer
    SET @SQL = 

	-- se usan las concatenacion para hacerlo dinamico (como si fuera java) 
    'CREATE DATABASE [' + @NombreDB + '] ON 
    ( NAME = N''' + @NombreDB + '_Data'', 
      FILENAME = N''' + @RutaMDF + ''', 
      SIZE = ' + CAST(@TamanoInicialMDF AS NVARCHAR) + 'MB, 
      FILEGROWTH = ' + CAST(@CrecimientoMDF AS NVARCHAR) + 'MB )
    LOG ON 
    ( NAME = N''' + @NombreDB + '_Log'', 
      FILENAME = N''' + @RutaLDF + ''', 
      SIZE = ' + CAST(@TamanoInicialLDF AS NVARCHAR) + 'MB, 
      FILEGROWTH = ' + CAST(@CrecimientoLDF AS NVARCHAR) + 'MB )';

	  -- CAST(@TamanoInicialMDF AS NVARCHAR) ayuda a convertir cada valor numerico a txt, esto ayuda a que la cadena sea nvarchar 
	  -- es mejor usar nvarchar para los sp ya que permiten almacenar texto unicode (UTF-16) y varchar no, es decir
	  --Texto Unicode = Texto con caracteres especiales o internacionalización.

    -- Con este comando se ejecuta es sp 
    EXEC sp_executesql @SQL;
    
    PRINT 'Base de datos [' + @NombreDB + '] creada exitosamente.';
END;


-- EJEMPLO
EXEC sp_CrearBaseDatos 
    @NombreDB = 'MiBaseDeDatos',
    @RutaMDF = 'C:\SQLData\MiBaseDeDatos.mdf',
    @TamanoInicialMDF = 50,
    @CrecimientoMDF = 10,
    @RutaLDF = 'C:\SQLData\MiBaseDeDatos_log.ldf',
    @TamanoInicialLDF = 10,
    @CrecimientoLDF = 5;
	go

----------------------------------------------------------------------------------------------------------------------------------------------------
------PROCEDURE PARA CREAR BASES DE DATOS CON VALIDACIONES BASICAS-----------

	CREATE or alter PROCEDURE sp_CrearBaseDatosValidacion
    @NombreDB NVARCHAR(100),
    @RutaMDF NVARCHAR(255),
    @TamanoInicialMDF INT,  
    @CrecimientoMDF INT,     
    @RutaLDF NVARCHAR(255),
    @TamanoInicialLDF INT,   
    @CrecimientoLDF INT    
AS
BEGIN
    -- Validar si la base de datos ya existe
    IF EXISTS (SELECT * FROM sys.databases WHERE name = @NombreDB)
    BEGIN
        PRINT 'La base de datos [' + @NombreDB + '] ya existe. Por favor, cambie el nombre de la base de datos.';
        RETURN;
    END

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = 
    'CREATE DATABASE [' + @NombreDB + '] ON 
    ( NAME = N''' + @NombreDB + '_Data'', 
      FILENAME = N''' + @RutaMDF + ''', 
      SIZE = ' + CAST(@TamanoInicialMDF AS NVARCHAR(10)) + 'MB, 
      FILEGROWTH = ' + CAST(@CrecimientoMDF AS NVARCHAR(10)) + 'MB )
    LOG ON 
    ( NAME = N''' + @NombreDB + '_Log'', 
      FILENAME = N''' + @RutaLDF + ''', 
      SIZE = ' + CAST(@TamanoInicialLDF AS NVARCHAR(10)) + 'MB, 
      FILEGROWTH = ' + CAST(@CrecimientoLDF AS NVARCHAR(10)) + 'MB )';

    BEGIN TRY
        EXEC sp_executesql @SQL;
        PRINT 'Base de datos [' + @NombreDB + '] creada exitosamente.';
		
    END TRY
    BEGIN CATCH
        PRINT 'Error al crear la base de datos: ' + ERROR_MESSAGE();
    END CATCH;
END;
go 


----------------------------------------------------------------------------------------------------------------------------------------------
-----PROCEDURE PARA PERMISOS DE USUARIOS-----

CREATE or alter PROCEDURE sp_PermisosUsuarios
    @LoginName NVARCHAR(100),
    @UserName NVARCHAR(100),
    @Password NVARCHAR(128),
    @DatabaseName NVARCHAR(128),
    @Permissions NVARCHAR(MAX),  -- Permisos concatenados con ';' (ejemplo: 'SELECT;INSERT')
    @Roles NVARCHAR(MAX)         -- Roles concatenados con ';' (ejemplo: 'db_datareader;db_datawriter')
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Crear login si no existe, usando el password proporcionado
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @LoginName)
    BEGIN
        SET @SQL = 'CREATE LOGIN [' + @LoginName + '] WITH PASSWORD = ''' + @Password + ''', CHECK_POLICY = OFF;';
        EXEC sp_executesql @SQL;
    END
    
    -- Verificar existencia de usuario en la base de datos seleccionada
    DECLARE @UserCount INT = 0;
    SET @SQL = 'USE [' + @DatabaseName + ']; SELECT @UserCountOut = COUNT(*) FROM sys.database_principals WHERE name = ''' + @UserName + ''';';
    EXEC sp_executesql @SQL, N'@UserCountOut INT OUTPUT', @UserCountOut=@UserCount OUTPUT;
    
    -- Crear usuario en la base de datos seleccionada si no existe
    IF @UserCount = 0
    BEGIN
        SET @SQL = 'USE [' + @DatabaseName + ']; CREATE USER [' + @UserName + '] FOR LOGIN [' + @LoginName + '];';
        EXEC sp_executesql @SQL;
    END

    -- Asignar permisos (a nivel de base de datos)
    DECLARE @Permission NVARCHAR(50);
    DECLARE PermCursor CURSOR FOR 
        SELECT value FROM STRING_SPLIT(@Permissions, ';') WHERE value <> '';
    
    OPEN PermCursor;
    FETCH NEXT FROM PermCursor INTO @Permission;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = 'USE [' + @DatabaseName + ']; GRANT ' + @Permission + ' ON DATABASE::[' + @DatabaseName + '] TO [' + @UserName + ']';
        EXEC sp_executesql @SQL;
        FETCH NEXT FROM PermCursor INTO @Permission;
    END
    CLOSE PermCursor;
    DEALLOCATE PermCursor;
    
    -- Asignar roles
    DECLARE @Role NVARCHAR(100);
    DECLARE RoleCursor CURSOR FOR 
        SELECT value FROM STRING_SPLIT(@Roles, ';') WHERE value <> '';
    
    OPEN RoleCursor;
    FETCH NEXT FROM RoleCursor INTO @Role;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = 'USE [' + @DatabaseName + ']; ALTER ROLE [' + @Role + '] ADD MEMBER [' + @UserName + ']';
        EXEC sp_executesql @SQL;
        FETCH NEXT FROM RoleCursor INTO @Role;
    END
    CLOSE RoleCursor;
    DEALLOCATE RoleCursor;
END;



go

DROP PROCEDURE sp_PermisosUsuarios;
SELECT * FROM sys.tables WHERE name = 'bdPrueba';

CREATE TABLE HistorialOperaciones (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Operacion NVARCHAR(200),
    Usuario NVARCHAR(100),
    Fecha DATETIME DEFAULT GETDATE()
);
go

exec sp_CrearBaseDatosValidacion
	@NombreDB = 'MiBaseDeDatos',
    @RutaMDF = 'C:\Data\ldf\MiBaseDeDatos.mdf',
    @TamanoInicialMDF = 50,
    @CrecimientoMDF = 10,
    @RutaLDF = 'C:\Data\mdf\MiBaseDeDatos_log.ldf',
    @TamanoInicialLDF = 10,
    @CrecimientoLDF = 5;
	go 


	CREATE DATABASE [MiBaseDeDatos] ON 
    ( NAME = N'MiBaseDeDatos_Data', 
      FILENAME = N'C:\Data\ldf\MiBaseDeDatos.mdf', 
      SIZE = 50MB, 
      FILEGROWTH = 10MB )
    LOG ON 
    ( NAME = N'MiBaseDeDatos_Log', 
      FILENAME = N'C:\Data\mdf\MiBaseDeDatos_log.ldf', 
      SIZE = 10MB, 
      FILEGROWTH = 5MB )
	  go
------------------------------------------------------------------------------------------------------------------------------------------------------
--------SP PARA BACKUPS-----------------
CREATE OR ALTER PROCEDURE sp_RespaldarBaseDatos
    @NombreBaseDatos NVARCHAR(128),
    @TipoBackup NVARCHAR(20) -- Valores: 'FULL', 'DIFFERENTIAL', 'LOG'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de parámetros
    IF @NombreBaseDatos IS NULL OR LTRIM(RTRIM(@NombreBaseDatos)) = ''
        THROW 50000, 'El nombre de la base de datos es requerido', 1;

    IF @TipoBackup NOT IN ('FULL', 'DIFFERENTIAL', 'LOG')
        THROW 50001, 'El tipo de backup debe ser FULL, DIFFERENTIAL o LOG', 1;

    -- Validar que la base de datos exista
    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @NombreBaseDatos)
        THROW 50002, 'La base de datos especificada no existe', 1;

    /*
      Definir la ruta base donde se almacenarán los backups.  
      En un entorno Docker se debe montar un volumen en la ruta (por ejemplo, /Backups).
    */
    DECLARE @BaseBackupPath NVARCHAR(500) = 'C:\BackPrueba\Backups';

    -- Determinar la subcarpeta según el tipo de backup
    DECLARE @SubCarpeta NVARCHAR(50);
    IF @TipoBackup = 'FULL'
        SET @SubCarpeta = 'Full';
    ELSE IF @TipoBackup = 'DIFFERENTIAL'
        SET @SubCarpeta = 'Differential';
    ELSE IF @TipoBackup = 'LOG'
        SET @SubCarpeta = 'Log';

    -- Construir la ruta completa: /Backups/<DatabaseName>/<SubCarpeta>/
    DECLARE @RutaCompleta NVARCHAR(500) = @BaseBackupPath + '\' + @NombreBaseDatos + '\' + @SubCarpeta + '\';

    -- Crear la carpeta si no existe (nota: xp_create_subdir crea la ruta completa)
    EXEC master.dbo.xp_create_subdir @RutaCompleta;

    -- Generar el nombre del archivo de respaldo con timestamp
    DECLARE @NombreArchivo NVARCHAR(500) = @RutaCompleta + @NombreBaseDatos + '_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') +
        CASE 
            WHEN @TipoBackup = 'FULL' THEN '_full.bak'
            WHEN @TipoBackup = 'DIFFERENTIAL' THEN '_diff.bak'
            WHEN @TipoBackup = 'LOG' THEN '_log.trn'
        END;

    -- Construir el comando de backup según el tipo solicitado
    DECLARE @ComandoBackup NVARCHAR(MAX);
    IF @TipoBackup = 'FULL'
        SET @ComandoBackup = 'BACKUP DATABASE [' + @NombreBaseDatos + '] TO DISK = ''' + @NombreArchivo + ''' WITH COMPRESSION, STATS = 5';
    ELSE IF @TipoBackup = 'DIFFERENTIAL'
        SET @ComandoBackup = 'BACKUP DATABASE [' + @NombreBaseDatos + '] TO DISK = ''' + @NombreArchivo + ''' WITH DIFFERENTIAL, COMPRESSION, STATS = 5';
    ELSE IF @TipoBackup = 'LOG'
        SET @ComandoBackup = 'BACKUP LOG [' + @NombreBaseDatos + '] TO DISK = ''' + @NombreArchivo + ''' WITH COMPRESSION, STATS = 5';

    PRINT @ComandoBackup;
    EXEC sp_executesql @ComandoBackup;

    SELECT 'Backup generado en: ' + @NombreArchivo AS Mensaje;
END;




GO
