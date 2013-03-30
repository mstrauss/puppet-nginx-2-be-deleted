# Define: nginx::server
#   Use as virtual resource!  It will then be realized by the given instance.
# Parameters:
#   $title: a unique name, e.g. 'www.example.org'
#   $instance: an nginx instance (created by nginx::instance) which will realize this vhost.
#
define nginx::server(
  $instance,
  $path           = undef,
  $path_postfix   = '',
  $root           = undef,
  $confdir        = undef,
  $confname       = "${title}.conf",
  $owner          = root,
  $group          = root,
  $port           = 80,
  $default_server = false,
  $manage_paths   = false,
  $ensure         = present
) {
  
  #######################
  # Dependency handling #
  #######################
  
  anchor{ "nginx::begin::${title}":
    before => Instance[$instance],
    notify => Exec["nginx-reload-${instance}"],
  }
  anchor { "nginx::end::${title}":
    require => Exec["nginx-reload-${instance}"],
  }
  
  ######################
  # Parameter mangling #
  ######################
  
  if( $path == undef ) {
    $__basepath = $nginx::setup::common_dataroot
    $_path = "${__basepath}/${title}/${path_postfix}"
  } else {
    $_path = $path
  }
  
  if( $root == undef ) {
    $_root = "${_path}/public"
  } else {
    $_root = $root
  }
  
  if( $confdir == undef ) {
    $_confdir = "${_path}/config"
  } else {
    $_confdir = $confdir
  }
  
  $_confname = $confname
  $_confpath = "${_confdir}/${_confname}"
  
  $_owner = $owner
  $_group = $group
  $_port  = $port
  $_default_server = $default_server
  
  # config directory (where vhost custom configuration can be placed)
  $__local_confpath = "${_path}/config"
  
  # ---> from now on, use only underlined variables (except $title and $ensure) <----
  if $manage_paths == true {
    if $ensure == present {
      
      # vhost base directory
      file { "${_path}": ensure => directory, owner => $_owner, group => $_group }
      
      # config directory (where vhost custom configuration can be placed)
      file { $__local_confpath: ensure => directory, owner => $_owner, group => $_group }
      
      # root directory (where our static files are served from)
      file { "${_root}": ensure => directory, owner => $_owner, group => $_group }
      
    } else {
      
      # base directory cleanup
      file { "${_path}": ensure => absent, recurse => true, force => true }
      
      # config cleanup
      file { "${_confpath}": ensure => absent }
    }
  }
  
  # server/vhost configuration file
  file { "${_confpath}":
    content => template( 'nginx/nginx-server.conf.erb' ),
    owner   => $_owner,
    group   => $_group,
    notify  => $ensure ? {
      absent  => undef,
      default => Exec["nginx-reload-${instance}"],
    },
    ensure  => $ensure ? {
       absent => absent,
      default => present,
    },
  }
  
}
