dnf -y update

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

# erase fragtation funciton. this function you use vagrant package.
cat << END >> ~/.bash_profile
# eraze fragtation.
function defrag () {
    dd if=/dev/zero of=/EMPTY bs=1M; rm -f /EMPTY
}
END

