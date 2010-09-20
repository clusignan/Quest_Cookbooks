maintainer "Alex Pop"
maintainer_email "alex@rightscale.com"
license "All rights reserved"
description "Installs/Configures lb_haproxy"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version "0.0.2"

recipe "lb_haproxy::do_attach_request", "Attaches an application server to the load balancer"

attribute "lb_haproxy/applistener_name",
  :display_name => "Applistener Name",
  :description => "Sets the name of the HAProxy load balance pool on frontends in /home/haproxy/rightscale_lb.cfg. Application severs will join this load balance pool by using this name. Ex: www",
  :recipes => [ 'lb_haproxy::do_attach_request'],
  :required => "required"
