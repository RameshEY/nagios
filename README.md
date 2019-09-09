# Nagios Installation using Ansible 

### Configure Ansible Server 

```
vi nagiosserver_playbook.yaml

# Edit the host section and add your nagios server host 

ansible-playbook nagiosserver_playbook.yaml
```
***

### Configure Ansible remote host 

```
vi nagioshost_playbook.yaml

# Edit the host section and add your nagios remote host 

ansible-playbook nagioshost_playbook.yaml
```

***

### Log in to Nagios GUI 

Browse to : `http://YOUR_MASTER_EXTERNAL_IP_ADDRESS/nagios ` to access nagios UI. 

Use the password and username set in the playbook to access (nagiosadmin/nagiosadmin in our case) 

***

### Configure Nagios remote host 

```
vi /etc/nagios/nrpe.cfg
```

### Search for server_address 

1. Uncomment server_address 

```
#server_address=127.0.0.1

TO 

server_address=127.0.0.1

```

2. Change the IP address from 127.0.0.1 to Nagios **SERVER** IP address

```
server_address=127.0.0.1

TO

server_address=YOUR_NAGIOS_SERVER_INTERNAL_IP

```

***

### Configure Nagios Server to contact Nagios remote host 

```
vi /usr/local/nagios/etc/nagios.cfg
```

Uncomment the below line number 51 - 

```
#cfg_dir=/usr/local/nagios/etc/servers

TO

cfg_dir=/usr/local/nagios/etc/servers

```

Create the directory **servers**

```
mkdir -p /usr/local/nagios/etc/servers
```

Create a configuration to add remote ubuntu host 


```
vi /usr/local/nagios/etc/servers/ubuntu_host.cfg
```


Add the below lines - 

```
define host {
        use                          linux-server
        host_name                    ubuntu_host
        alias                        Ubuntu Host
        address                      YOUR_REMOTE_INTERNAL_IP_ADDRESS
        register                     1
}

define service {
      host_name                       ubuntu_host
      service_description             PING
      check_command                   check_ping!100.0,20%!500.0,60%
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}

define service {
      host_name                       ubuntu_host
      service_description             Check Users
      check_command           check_local_users!20!50
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}

define service {
      host_name                       ubuntu_host
      service_description             Local Disk
      check_command                   check_local_disk!20%!10%!/
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}

define service {
      host_name                       ubuntu_host
      service_description             Check SSH
      check_command                   check_ssh
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}

define service {
      host_name                       ubuntu_host
      service_description             Total Process
      check_command                   check_local_procs!250!400!RSZDT
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1
}

```


Verify Configuration - 

```
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

```

Your output should be as below - 

```
Checking objects...
        Checked 13 services.
        Checked 2 hosts.
        Checked 1 host groups.
        Checked 0 service groups.
        Checked 1 contacts.
        Checked 1 contact groups.
        Checked 24 commands.
        Checked 5 time periods.
        Checked 0 host escalations.
        Checked 0 service escalations.
Checking for circular paths...
        Checked 2 hosts
        Checked 0 service dependencies
        Checked 0 host dependencies
        Checked 5 timeperiods
Checking global event handlers...
Checking obsessive compulsive processor commands...
Checking misc settings...

Total Warnings: 0
Total Errors:   0

Things look okay - No serious problems were detected during the pre-flight check

```

***

### Install nrpe server on master 

```
apt-get install nagios-nrpe-server -y 
```

***

### Restart all services 

1. On Nagios host

```
systemctl restart nagios-nrpe-server.service
```

2. On Nagios server 

```
service apache2 restart
service nagios restart

```


***

### Create a Custom script to monitor process


1. Move the custom script to plugin location 

```
cp check_kubelet.sh /usr/local/nagios/libexec/check_kubelet.sh

chmod +x /usr/local/nagios/libexec/check_kubelet.sh

```

2. Create a new command that will be recognized by nagios 

```
vi /usr/local/nagios/etc/objects/commands.cfg
```

3. Add the below definition for the new command check_kubelet

```
define command{
	command_name check_kubelet
	command_line $USER1$/check_kubelet.sh
}

```

4. Add the below block to execute the command on nagios server 

```
vi /usr/local/nagios/etc/objects/localhost.cfg
```

Add the below lines - 

```
define service{
	use local-service
	host_name localhost
	service_description Nagios kubelet monitoring
	check_command check_kubelet
}

```

5. Verify configuration

```
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

```

6. Add the configuration to remote host - 

```
vi /usr/local/nagios/etc/servers/ubuntu_host.cfg

# Add the below lines 

define service{
      host_name                       ubuntu_host
      service_description             kubelet_check
      check_command                   check_kubelet
      max_check_attempts              2
      check_interval                  2
      retry_interval                  2
      check_period                    24x7
      check_freshness                 1
      contact_groups                  admins
      notification_interval           2
      notification_period             24x7
      notifications_enabled           1
      register                        1

}


```

7. Restart nagios service 

```
systemctl restart nagios.service 
```




















