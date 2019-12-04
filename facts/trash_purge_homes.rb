require 'yaml'

##facter with users whose homes must be purged from trash (status=purge)

#to debug, use STDERR and run 'puppet facts --debug | grep -A 20 trash_purge_homes' in the agent

Facter.add(:trash_purge_homes) do

  setcode do
    #build hash with users homes that need to be purged
    homestopurge = {}
    #get all users to purge from trash
    users=Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s one -b "ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
    if not users.nil?
      users.each_line do |user|
       trashname = Facter::Util::Resolution.exec('ldapsearch -H ldapi:// -Y EXTERNAL -LLL -s base -b "cn=' + user.strip + ',ou=users,ou=trash,dc=example,dc=tld" "(&(objectClass=applicationProcess)(status=purge))" | grep cn: | sed "s|.*: \(.*\)|\1|"')
       homestopurge[user.strip] = {:uid => user.strip ,:trashname => trashname.strip}
      end
    end
    homestopurge
  end

end
