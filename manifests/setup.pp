# Class: nginx::setup
#
#
class nginx::setup {

  require build-essential
  
  $debian_packages = ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  package{ $debian_packages: ensure => installed }
  
  
  # create global directories
  file { instance_basepath:
    path => hiera('nginx_common_binroot'),
    ensure => directory,
  }
  file { server_basepath:
    path => hiera('nginx_common_dataroot'),
    ensure => directory,
  }
}
