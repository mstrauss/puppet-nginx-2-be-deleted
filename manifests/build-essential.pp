# Class: build-utilities
#
#
class build-essential {
  # resources
  $debian_packages = ['build-essential']
  package { $debian_packages: ensure => installed }
}
