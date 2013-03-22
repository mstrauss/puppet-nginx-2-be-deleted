puppet-nginx
============

**THIS SOFTWARE IS VERY ALPHA.**

When finished, it supports

* managing multiple nginx instances, all compiled from source
* mutliple servers (vHosts) per instance

Requirements: 

* Puppet 3.x with configured Hiera
* OSes: Debian/Ubuntu

Example Hiera Configuration
---------------------------

    ---
    nginx_common_binroot: /opt/nginx
    nginx_common_buildroot: /var/cache/nginx
    nginx_common_dataroot: /var/www/nginx
    nginx_instances:
      port80:
        version: 1.2.7
        user: nginx
        group: nginx
      port8080:
        version: 1.3.14
        user: nobody
        group: nogroup
    nginx_servers:
      www.example.com:
        instance: port80
      www.example.org:
        instance: port80
        default_server: true
      test:
        instance: port8080

This example

* installs two instances of nginx
* installs two vhosts for instance `port80` and one for `port8080`
* all vhosts are placed in `/var/www/nginx`

