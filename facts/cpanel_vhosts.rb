require 'yaml'
require 'etc'

##facter with vhost params for each domain

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 cpanel_vhosts' in the agent

Facter.add(:cpanel_vhosts, :type => :aggregate ) do

  #domain name
  chunk(:domain) do
    vhosts = {}
    Facter.value(:cpanel_domains).each do |domain, value|
      vhosts[domain.strip] = value
    end
    vhosts
  end

  #webmaster and webmaster_type
  chunk(:webmaster) do
    vhosts = {}
    #get ssh user uid
    adminuid = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=sshd,ou=People,dc=example,dc=tld" "(&(objectClass=person)(uid=*)(gidnumber=27))" | grep uid: | sed "s|.*: \(.*\)|\1|"')
    Facter.value(:cpanel_domains).each do |domain, value|
      webmaster=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "vd=' + domain.strip + ',o=hosting,dc=example,dc=tld" "(objectClass=VirtualDomain)" | grep adminID: | sed "s|.*: \(.*\)|\1|"')
      if not webmaster == 'nobody' and not webmaster == adminuid
        vhosts[domain.strip] = {:webmaster => webmaster.strip, :webmaster_type => Facter.value(:cpanel_users)[webmaster.strip][:type]}
      else
        if webmaster == 'nobody'
          vhosts[domain.strip] = {:webmaster => webmaster.strip, :webmaster_type => 'nobody'}
        else
          vhosts[domain.strip] = {:webmaster => webmaster.strip, :webmaster_type => 'sudo'}
        end
      end
    end

    vhosts
  end

  #oldwebmaster: the current owner of the webroot folder
  chunk(:oldwebmaster) do
    vhosts = {}
    Facter.value(:cpanel_domains).each do |domain, value|
      webroot = '/var/www/html/' + domain.strip
      if File.directory?(webroot)
        uid = File.stat(webroot).uid
        username = Etc.getpwuid(uid).name
        vhosts[domain.strip] = {:oldwebmaster => username}
      else
        vhosts[domain.strip] = {:oldwebmaster => ''}
      end
    end
    vhosts
  end


  #todo, add extra vhosts options to parse in the template file

end

