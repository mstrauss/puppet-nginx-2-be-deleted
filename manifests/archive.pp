define nginx::archive($source, $target, $timeout = 1800) {
  if !defined( Package[curl] ) {
    package { curl: ensure => installed }
  }
  exec {"$name unpack":
    require => Package[curl],
    command => "/usr/bin/curl ${source} | /bin/tar -xzf - -C ${target} && /usr/bin/touch '${target}/${name}'",
    creates => "${target}/${name}",
    timeout => $timeout,
  }
}
