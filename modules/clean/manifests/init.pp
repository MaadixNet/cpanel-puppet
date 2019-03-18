class clean (
  $enabled = str2bool("$::clean"),
) {

  validate_bool($enabled)

  if $enabled {

    #clean downloaded packages
    exec { 'clean apt':
      command => '/usr/bin/apt-get clean',
    }

    #clean unused images and containers
    #https://github.com/spotify/docker-gc
    if ($::docker_group){
      exec { 'clean docker':
        command   => '/usr/bin/docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc -e GRACE_PERIOD_SECONDS=10 spotify/docker-gc',
        logoutput => true,
      }
    }

  }

}
