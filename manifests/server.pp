# Define: nginx::server
# Parameters:
#   $title: server name
#   $srvpath:  the directory where the server will be created
#   $root:  root directory
#
define nginx::server(
  $instance,
  $srvpath  = undef,
  $root     = undef,
  $confdir  = undef,
  $confname = "nginx.conf",
  $owner    = root,
  $group    = root,
  $port     = 80,
  $default_server = false,
  $ensure   = present
) {
  
  #######################
  # Dependency handling #
  #######################
  
  # at parse time: we are going to use their class variables, so this class needs to be parsed already
  if !defined(Class[$instance]) {
    fail( "We need Class[$instance] variables to be already available here!")
  }
  
  # at run time: this server is handled after all class resources
  Class[$instance] -> Nginx::Server[$title]
  
  ######################
  # Parameter mangling #
  ######################
  # $::nginx::basepath
  $_basepath = $::$instance::basepath
  
  if( $srvpath == undef ) {
    $_srvpath = "${_basepath}/${title}"
  } else {
    $_srvpath = $srvpath
  }
  
  if( $root == undef ) {
    $_root = "${_srvpath}/public"
  } else {
    $_root = $root
  }
  
  if( $confdir == undef ) {
    $_confdir = "${_srvpath}/config"
  } else {
    $_confdir = $confdir
  }
  
  $_confname = $confname
  
  $_confpath = "${_confdir}/${_confname}"
  
  $_owner = $owner
  $_group = $group
  $_port  = $port
  $_default_server = $default_server
  
  # ---> from now on, use only underlined variables (except $title and $ensure) <----
    
  if $ensure == present {
    
    # base directory
    file { "${_srvpath}": ensure => directory, owner => $_owner, group => $_group }
    
    # root directory (where our static files are served from)
    file { "${_root}": ensure => directory, owner => $_owner, group => $_group }
    
    # config directories
    file { "${_confdir}":          ensure => directory, owner => $_owner, group => $_group }
    file { "${_confdir}/config.d": ensure => directory, owner => $_owner, group => $_group }
    
    # configuration file
    file { "${_confpath}":
      content => template( 'nginx/nginx.conf.erb' ),
      owner   => $_owner,
      group   => $_group,
    }
  }
}
