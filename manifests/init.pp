# Class: nginx
#
#
class nginx( $instances, $servers ) {
  
  require setup
  
  # binaries
  create_resources( nginx::instance, $instances )
  
  # vHosts aka Servers
  create_resources( "@nginx::server", $servers )
  
}
