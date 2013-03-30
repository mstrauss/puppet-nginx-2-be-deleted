# Class: nginx::setup
#
#
class nginx::setup( $common_binroot, $common_buildroot, $common_dataroot ) {

  require build-essential
  
  $debian_packages = ['libpcre3', 'libpcre3-dev', 'libssl-dev']
  package{ $debian_packages: ensure => installed }
  
  
  # create global directories
  file { instance_basepath:
    path => $common_binroot,
    ensure => directory,
  }
  file { server_basepath:
    path => $common_dataroot,
    ensure => directory,
  }
}
