# Define: nginx::instance
#
# An nginx instance has this structure:
#
# nginx_common_binroot [e.g. /opt]
# `-- nginx-[instance title]
#     |-- html [supporting files]
#     |-- logs [log files]
#     `-- sbin [the binaries]
#         `-- nginx


define nginx::instance(
  $version,
  $buildroot = undef,
  $binroot   = undef,
  # $dataroot  = undef,
  $user,
  $group,
  $ensure = present
) {
  
  #######################
  # Dependency handling #
  #######################
  require setup
  
  ######################
  # Parameter mangling #
  ######################
  
  $_instance_name   = "${title}-${version}"
  $_common_binroot  = hiera('nginx_common_binroot')
  $_common_buildroot  = hiera('nginx_common_buildroot')
  # $_common_dataroot = hiera('nginx_common_dataroot')
  
  if( $binroot == undef ) {
    $_binroot = "${_common_binroot}/${_instance_name}"
  } else {
    $_binroot = $binroot
  }
  
  if( $buildroot == undef ) {
    $_buildroot = "${_common_buildroot}/${_instance_name}"
  } else {
    $_buildroot = $buildroot
  }
  
  # if( $dataroot == undef ) {
  #   $_dataroot = "${_common_dataroot}/${_instance_name}"
  # } else {
  #   $_dataroot = $dataroot
  # }
  
  ######################
  # Internal variables #
  ######################
  
  $__confpath = "${_binroot}/conf"
  $__configure_flags = "--prefix=${_binroot} --conf-path=${__confpath}/nginx.conf --user=${user} --group=${group} --with-http_ssl_module"
  $__compile = "compile-${_instance_name}"
  $__compile_creates = "${_binroot}/sbin/nginx"
  
  Archive[$_instance_name] ~> Exec[$__compile]
  
  if !defined(File[$_buildroot]) {
    file { $_buildroot: ensure => directory }
    File[$_buildroot] -> Archive[$_instance_name]
  }
  archive { $_instance_name:
    source => "http://nginx.org/download/nginx-${version}.tar.gz",
    target => $_buildroot,
  }
  exec { $__compile:
    provider => shell,
    cwd      => "${_buildroot}/nginx-${version}",
    command  => "./configure ${__configure_flags} && make && make install",
    unless   => "(${__compile_creates} -V 2>&1 | fgrep '${version}') && (${__compile_creates} -V 2>&1 | fgrep -- '${__configure_flags}')"
  }
  
  # # vHost preparations
  # file { "${_dataroot}": ensure => directory, recurse => true }
  # 
  # # global instance config
  # file { "${__confpath}": ensure => directory }
  
  # vHost master configs
  $__vhost_config_path = "${__confpath}/vhost.d"
  file { $__vhost_config_path: ensure => directory }
  Exec[$__compile] -> File[$__vhost_config_path]
  
  file { "${__confpath}/nginx.conf":
    content => template( 'nginx/nginx-instance.conf.erb' )
  }
  Exec[$__compile] -> File["${__confpath}/nginx.conf"]
  
  # collect all vhost/server definitions
  Server <| instance == $title |> {
    confdir => $__vhost_config_path
  }
}
