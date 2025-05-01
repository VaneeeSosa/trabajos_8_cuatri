-- backup completo
backup database AdventureWorks2022
to disk ='\backups\backupAdventure.bak' -- se agrega doble para lo remoto \\ruta_del_otro_servidor_con_la_carpeta_compartida
-- en el .bak tendra todos los back que hagamos, completos, diferenciales, etc.
with 
name='backupCompleto_03_03_2025',
description = 'backup completo de AdventureWorks'
go

-- backup diferencial
backup database AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with
name='BackupDiferencial1_04_03_2025',
description='backup diferencial 1 de AdventureWorks2022',
differential

--backup de log de transacciones
-- propiedades de la tabla, options, full, abrir y cerrar el sql y ya se puede hacer 
backup log AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with
name='BackupLog1',
description='backup de log de transacciones 1'

--Backup de solo copia
backup database AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with 
copy_only,
name='backupSoloCopia',
description='Backup solo copia'

--backup de filegroup/parciales
backup database AdventureWorks2022
filegroup='primary'
to disk ='\backups\backupAdventure.bak'
with
name='AdventureWorks_Filegroup_primary'

--backup de la cola de log, lo ultimo q se encuentra de la bd por si le pasa algo, lo ultimo q se hizo
backup log AdventureWorks2022
to disk ='\backups\backupAdventure.bak'
with 
recovery,
name='Adventure_log_cola'