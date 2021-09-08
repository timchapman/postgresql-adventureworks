# AdventureWorks database for Azure Database for PostgreSQL

AdventureWorks 2016 database backup converted to PostgreSQL schema.  Once you have provisioned an Azure Database for PostgreSQL Single or Flexible Server, use the following commands to restore the database:
1.  Download and install PGAdmin:  https://www.pgadmin.org/download/
2.  Navigate to where PGAdmin is installed (default location of C:\Program Files\pgAdmin 4\v5\runtime) and open a Command Prompt.
3.  Execute the following pg_restore command:  
pg_restore -h yourpostgresqlservername.postgres.database.azure.com -U timchapman  -d adventureworks C:/temp/SQL/AdventureWorksPG.gz
