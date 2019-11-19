class domains (
  $enabled   = str2bool("$::domains"),
  $vhost_dir = '/etc/apache2/ldap-enabled',
) {

  validate_bool($enabled)

  if $enabled {

    ## tasks in order ##

    #ensure /home/.trash folder
    file {'/home/.trash':
      ensure  => directory,
    }->
    file {'/home/.trash/users':
      ensure  => directory,
    }

    #purge ldap-enabled vhost dir
    file { $vhost_dir:
      ensure  => directory,
      recurse => true,
      purge   => true,
      notify  => Exec['reload apache'],
    }

    #ensure sftpuser home folders to mount domains
    create_resources(domains::sftpusershome, $::cpanel_users)

    #umount domains (deleted or assigned to a different user)
    create_resources(domains::umount, $::cpanel_umount)

    #create vhosts (vhost, webroot, letsencrypt cert)
    create_resources(domains::vhosts, $::cpanel_vhosts)

    #mount domains
    create_resources(domains::mounts, $::cpanel_vhosts)

    #clean orphan domains (certs and permissions)
    create_resources(domains::orphandomains, $::cpanel_orphan_vhosts)

    #move orphan users homes to trash
    create_resources(domains::orphanhomes, $::cpanel_orphan_homes)

    ## utilities ##

    #reload apache
    exec {'reload apache':
      command     => 'service apache2 reload',
      path	  => ['/usr/bin', '/usr/sbin', '/bin'],
      refreshonly => true,
    }

    #reload apache end
    exec {'reload apache end':
      command     => 'service apache2 reload',
      path	  => ['/usr/bin', '/usr/sbin', '/bin'],
      refreshonly => true,
    }



  }

}
