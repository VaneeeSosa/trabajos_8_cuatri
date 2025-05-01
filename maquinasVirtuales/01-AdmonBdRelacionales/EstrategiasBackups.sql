--Estrategias de backups
-- 1. completos
-- 2. completos+diferenciales
-- 3. completos+diferenciales+log de transacciones

--backup completo
backup database AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with 
name='BackupCompleto_03_03_2025',
description = 'primer backup completo'
go
use AdventureWorks2022
insert into Person.person(PARAMETROS)
values(Parametros)

use master
backup log AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with
name='BackupLog2',
description='backup de log de transacciones 2 pero ahora si con transacciones'
go
use AdventureWorks2022
insert into Person.person(PARAMETROS)
values(Parametros);

--backup diferencial
backup database AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with
name='BackupDiferencial1_04_03_2025',
description='backup diferencial 1 de AdventureWorks2022',
differential
go

use AdventureWorks2022
insert into Person.person(PARAMETROS)
values(Parametros);

-- borrar la bd para despues recuperarla con los backs
drop database AdventureWorks2022;

-- restaurar full

--restaurar por logs
restore log Northwind
from disk = '\backups\backupAdventure.bak'
with file=4, norecovery --file es la posicion en la que se encuentra el log, lo puedes checar con el comando de abajo
go
-- revisar el archivo .bak, sirve para revisar lo q hay
restore headeronly
from disk ='\backups\backupAdventure.bak'



