define domains::cleanfailedvhosts(
  $domain               = undef,
  $webmaster            = undef,
  $webmaster_type       = undef,
  $www                  = undef,
  $regenerate           = undef,
  $dns                  = undef,
  $oldwebmaster         = undef,
) {

  if $dns {
    #delete non-ssl vhosts of domains without certificate / in case certbot fails
    exec {"delete $domain if certbot has failed":
      command      => "rm /etc/apache2/ldap-enabled/$domain.conf",
      logoutput    => true,
      unless       => "test -d /etc/letsencrypt/live/$domain",
      path         => ['/usr/bin', '/usr/sbin', '/bin'],
    }
  }

}
