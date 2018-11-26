OkComputer.mount_at = false

class LDAPCheck < OkComputer::Check
  def check
    if LdapSearch.in_organization('JFBK').length > 0
      mark_message('ok')
    else
      mark_failure
      mark_message('Unable to query organization membership')
    end
  end
end

OkComputer::Registry.register 'ldap', LDAPCheck.new
OkComputer::Registry.register 'http_libraries_url_check', OkComputer::HttpCheck.new(Settings.library.profile_url + 'subject-libraries')
