# Define: nginx::directive
# Parameters:
#   $title: a unique name
#   $server: where shall the directive apply
#
define nginx::directive ( $instance, $server, $content ) {
  
  Nginx::Instance[$instance] -> Nginx::Server[$server] -> Nginx::Directive[$title]
  
}
