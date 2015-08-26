require 'net/http'
class Person < OpenStruct
  include ActiveSupport::Benchmarkable

  def self.find(suRegID)
    hash = Rails.cache.fetch("person/#{suRegID}", expires_in: 3.hours) do
      LdapSearch.person_info(suRegID: suRegID)
    end
    new(hash) if hash
  end

  def self.find_by_uid(uid)
    hash = Rails.cache.fetch("person/#{uid}", expires_in: 3.hours) do
      LdapSearch.person_info(uid: uid)
    end
    new(hash) if hash
  end

  def self.in_organization(admin_id)
    LdapSearch.in_organization(admin_id).map { |uid| find_by_uid(uid) }.compact
  end

  def initialize(hash)
    super(hash)
  end

  def id
    suRegID
  end

  def suPrimaryOrganizationID
    self['suPrimaryOrganizationID'] || authed_data['suPrimaryOrganizationID'] || 'MISSING'
  end

  def suPrimaryOrganizationName
    @suPrimaryOrganizationName ||= I18n.t(:"directory.suPrimaryOrganizationID.#{suPrimaryOrganizationID}", default: [Organization.find_or_initialize_by(admin_id: suPrimaryOrganizationID).name, ou])
  end

  def lib_profile?
    return false unless uid.present?

    Rails.cache.fetch("people/drupal/#{org_code}/#{uid}", expires_in: 24.hours) do
      benchmark "People Page (#{uid})" do
        response = Hurley.head(Settings.library.profile_url + uid) do |req|
          req.options.redirection_limit = 0
          req.options.timeout = 6
        end

        response.success?
      end
    end
  end

  def stanford_who_url
    search_string = mail || Array(suSunetID).first || displayName.gsub(/\s/, '+')

    "http://stanfordwho.stanford.edu/SWApp/Search.do?search=#{search_string}"
  end

  private

  def authed_data
    @authed_data ||= Rails.cache.fetch("person/auth/#{uid}", expires_in: 3.hours) do
      LdapSearch.person_info(uid: uid, auth: true) || {}
    end
  end

  def logger
    Rails.logger
  end
end
