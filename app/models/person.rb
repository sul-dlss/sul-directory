require 'net/http'
class Person < OpenStruct
  include ActiveSupport::Benchmarkable

  ##
  # Find a user by their registry ID (note: this may require authenticated access)
  # @param [String] suRegID
  # @param [Hash] opts
  # @option opts [Boolean] :auth
  def self.find(suRegID, opts = {})
    hash = Rails.cache.fetch("person/#{suRegID}", expires_in: 24.hours) do
      LdapSearch.person_info(opts.merge(suRegID: suRegID))
    end
    new(hash) if hash
  end

  ##
  # Find a user by their primary sunetID
  # @param [String] uid
  # @param [Hash] opts
  # @option opts [Boolean] :auth
  def self.find_by_uid(uid, opts = {})
    hash = Rails.cache.fetch("person/#{uid}", expires_in: 24.hours) do
      LdapSearch.person_info(opts.merge(uid: uid))
    end
    new(hash) if hash
  end

  ##
  # Fetch all the users in a given organization
  def self.in_organization(admin_id)
    uids = Rails.cache.fetch("people/in/#{admin_id}", expires_in: 24.hours) do
      LdapSearch.in_organization(admin_id)
    end

    Parallel.map(uids) { |uid| find_by_uid(uid) }.compact
  end

  def initialize(hash)
    super(hash)
  end

  def id
    suRegID || uid
  end

  def suPrimaryOrganizationID
    self['suPrimaryOrganizationID'] || authed_data['suPrimaryOrganizationID'] || 'MISSING'
  end

  def suPrimaryOrganizationName
    @suPrimaryOrganizationName ||= I18n.t(:"directory.suPrimaryOrganizationID.#{suPrimaryOrganizationID}", default: [Organization.find_or_initialize_by(admin_id: suPrimaryOrganizationID).name, ou])
  end

  ##
  # Check if the user has a library "people page"
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

  ##
  # Try to construct a StanfordWho link for the user. This turns out to be harder
  # than expected because of the variety of privacy settings the user may have applied.
  # To do this better, we need to request access to those privacy settings so we 
  # can make an educated guess about the values that will actually turn up the 
  # given user..
  def stanford_who_url
    search_string = mail || Array(suSunetID).first || displayName.gsub(/\s/, '+')

    "http://stanfordwho.stanford.edu/SWApp/Search.do?search=#{search_string}"
  end

  private

  def authed_data
    @authed_data ||= Rails.cache.fetch("person/auth/#{uid}", expires_in: 24.hours) do
      LdapSearch.person_info(uid: uid, auth: true) || {}
    end
  end

  def logger
    Rails.logger
  end
end
