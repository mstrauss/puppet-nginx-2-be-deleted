# Class: nginx
#
#
class nginx {
  
  require setup
  
  # binaries
  create_resources(nginx::instance, hiera('nginx_instances'))
  
  # vHosts aka Servers
  create_resources("@nginx::server", hiera("nginx_servers"))
  
}
