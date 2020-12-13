dnf -y update

# install firewalld. firewalld is rhel,centos default dynamic firewall.
dnf -y install firewalld

# enabla firewalld.
systemctl enable firewalld
systemctl start firewalld

# port forwarding sqlserver port 1433.
firewall-cmd --add-port=1433/tcp --zone=public --permanent

# reload firewall settings.
firewall-cmd --reload

# install expect and pexpect for silent install.
dnf install -y expect
pip3 install pexpect

# install mssql-server
curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/8/mssql-server-2019.repo

dnf install -y mssql-server

SQLSERVER_PASSWORD="Zp3nopklvHyclwo0sco*"

python3 << END
import pexpect

# Express is 3
Edition = "3"
password = "$SQLSERVER_PASSWORD"


shell_cmd = "/opt/mssql/bin/mssql-conf setup"
prc = pexpect.spawn('/bin/bash', ['-c', shell_cmd],timeout=1200)

prc.expect("Enter your edition")
prc.sendline(Edition)

prc.expect("Do you accept the license terms")
prc.sendline("Yes")

prc.expect("Enter the SQL Server system administrator password")
prc.sendline(password)

prc.expect("Confirm the SQL Server system administrator password")
prc.sendline(password)

prc.expect( pexpect.EOF )
END

# install mssql-tools.
curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/8/prod.repo

python3 << END
import pexpect

shell_cmd = "dnf install -y mssql-tools unixODBC-devel"
prc = pexpect.spawn('/bin/bash', ['-c', shell_cmd],timeout=1200)

prc.expect("Do you accept the license terms")
prc.sendline("Yes")

prc.expect("Do you accept the license terms")
prc.sendline("Yes")

prc.expect( pexpect.EOF )
END

echo '# set sqlserver environment variable'  >> ~/.bash_profile
echo export PATH=\$PATH:/opt/mssql-tools/bin >> ~/.bash_profile
echo export SQLSERVER_PASSWORD=$SQLSERVER_PASSWORD >> ~/.bash_profile
echo '' >> ~/.bash_profile

cat << EOF >> ~/.bash_profile
# reference from [Microsoft site: Migrate from windows to linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database?view=sql-server-ver15)
# you want to know this script detail, go to https://github.com/microsoft/sql-server-samples.git
function enable_AdventureWorks () {
    # reference from [Microsoft site: AdventureWorks sample databases](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=tsql)
    mkdir \$HOME/AdventureWorks
    cd \$HOME/AdventureWorks
    curl -o AdventureWorks2019.bak -L https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2019.bak
    # move data directory
    mv AdventureWorks2019.bak /var/opt/mssql/data/
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    RESTORE DATABASE [AdventureWorks2019]
    FROM DISK = '/var/opt/mssql/data/AdventureWorks2019.bak'
    WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2019.mdf',
    MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/AdventureWorks2019_log.ldf',
    FILE = 1,  NOUNLOAD,  STATS = 5
    GO
EOF2
    curl -o AdventureWorksDW2019.bak -L https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2019.bak
    # move data directory
    mv AdventureWorksDW2019.bak /var/opt/mssql/data/
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    USE [master]
    RESTORE DATABASE [AdventureWorksDW2019]
    FROM DISK = '/var/opt/mssql/data/AdventureWorksDW2019.bak'
    WITH MOVE 'AdventureWorksDW2017' TO '/var/opt/mssql/data/AdventureWorksDW2019.mdf',
    MOVE 'AdventureWorksDW2017_log' TO '/var/opt/mssql/data/AdventureWorksDW2019_log.ldf',
    FILE = 1,  NOUNLOAD,  STATS = 5
    GO
EOF2
    cd - >> /dev/null
    rm -rf \$HOME/AdventureWorks

}

function disable_AdventureWorks () {
    # drop sample database.
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    USE [master];
    IF DB_ID('AdventureWorks2019') IS NOT NULL
    BEGIN
        DROP DATABASE AdventureWorks2019
    END
    IF DB_ID('AdventureWorksDW2019') IS NOT NULL
    BEGIN
        DROP DATABASE AdventureWorksDW2019
    END
    GO
EOF2
    # remove sample backup file.
    rm -f /var/opt/mssql/data/AdventureWorks2019.bak /var/opt/mssql/data/AdventureWorksDW2019.bak
}

EOF

cat << EOF >> ~/.bash_profile
# reference from [Microsoft site: Migrate from windows to linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-migrate-restore-database?view=sql-server-ver15)
# you want to know this script detail, go to https://github.com/microsoft/sql-server-samples.git
function enable_WideWorldImporters () {
    # reference from [Microsoft site: WideWorldImporters sample databases](https://docs.microsoft.com/en-us/sql/samples/wide-world-importers-dw-install-configure?view=sql-server-ver15)
    mkdir \$HOME/WideWorldImporters
    cd \$HOME/WideWorldImporters
    curl -o WideWorldImporters-Full.bak -L https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak
    # move data directory
    mv WideWorldImporters-Full.bak /var/opt/mssql/data/
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    USE [master]
    RESTORE DATABASE [WideWorldImporters]
    FROM DISK = '/var/opt/mssql/data/WideWorldImporters-Full.bak'
    WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImporters.mdf',
    MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
    MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImporters.ldf',
    MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1',
    FILE = 1,  NOUNLOAD,  STATS = 5
    GO

EOF2

    curl -o WideWorldImportersDW-Full.bak -L https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak
    # move data directory
    mv WideWorldImportersDW-Full.bak /var/opt/mssql/data/
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    USE [master]
    RESTORE DATABASE [WideWorldImportersDW]
    FROM DISK = '/var/opt/mssql/data/WideWorldImportersDW-Full.bak'
    WITH MOVE 'WWI_Primary' TO '/var/opt/mssql/data/WideWorldImportersDW.mdf',
    MOVE 'WWI_UserData' TO '/var/opt/mssql/data/WideWorldImportersDW_UserData.ndf',
    MOVE 'WWI_Log' TO '/var/opt/mssql/data/WideWorldImportersDW.ldf',
    MOVE 'WWIDW_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImportersDW_InMemory_Data_1',
    FILE = 1,  NOUNLOAD,  STATS = 5
    GO
EOF2
    cd - >> /dev/null
    rm -rf \$HOME/WideWorldImporters

}

function disable_WideWorldImporters () {
    # drop sample database WideWorldImporters.
    sqlcmd -S localhost -U SA -P \$SQLSERVER_PASSWORD << EOF2
    USE [master];
    IF DB_ID('WideWorldImporters') IS NOT NULL
    BEGIN
        DROP DATABASE WideWorldImporters
    END
    IF DB_ID('WideWorldImportersDW') IS NOT NULL
    BEGIN
        DROP DATABASE WideWorldImportersDW
    END
    GO
EOF2
    # remove sample backup file.
    rm -f /var/opt/mssql/data/WideWorldImporters-Full.bak /var/opt/mssql/data/WideWorldImportersDW-Full.bak
}

EOF

# erase fragtation funciton. this function you use vagrant package.
cat << END >> ~/.bash_profile
# eraze fragtation.
function defrag () {
    dd if=/dev/zero of=/EMPTY bs=1M; rm -f /EMPTY
}
END

reboot
