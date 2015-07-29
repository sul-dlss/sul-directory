Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  # Check the ActiveRecord database connection without spawning a new thread
  h.check :active_record, async: false

  # Check the mail server configured for ActionMailer
  h.check :action_mailer if ActionMailer::Base.delivery_method == :smtp

  h.check :url, get: Settings.library.profile_url + 'subject-libraries'

  h.check :ldap do |status|
    if LdapSearch.in_organization('JFBK').length > 0
      status.ok('ok')
    else
      status.fail('Unable to query organization membership')
    end
  end
end