# How_to_install_sqlserver_in_fedora

refference from [Microsoft Document how to install sqlserver in rhel](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-red-hat?view=sql-server-ver15)
# example script
this project has Vagrantfile.
```
vagrant up
```
sqlserver-fedora environment is being launch.

# install sample Database AdventureWorks2019 and AdventureWorksDW2019

```
# change user and read .bash_profile.
sudo su
source ~/.bash_profile

# execute bash function.
enable_sampleschema

# if you uninstall schema, execute below function
disable_sampleschema
```

# if you want to create vagrant box from vagrant file.

```
# stop vagrant environment
vagrant halt

# search virtualbox environment.
ls -1 ~/VirtualBox\ VMs/

# packaging your vagrant virtualbox environment. 
vagrant package --base <yourvirtualbox_environment_name> --output fedora33-sqlserver2019.box

# add box
vagrant box add localhost/fedora33-sqlserver2019 fedora33-sqlserver2019.box
```