# frozen_string_literal: true

# Wrapper for the `ldapsearch` command (we shell out so we can use SASL authentication
# with our kerberos credentials, because it's not clear we can do that from ruby-land
# reliably).
class LdapSearch
  class << self
    include ActiveSupport::Benchmarkable

    ##
    # Get the uids for members of an organization hierarchy
    # @param [String] an organization's admin_id
    # @return [Array<String>] an array of uids
    def in_organization(admin_id)
      admin_ids = Organization.in_tree(Organization.find_by(admin_id: admin_id)).pluck(:admin_id)
      Parallel.map(admin_ids) { |id| search(suprimaryorganizationid: id, auth: true, fields: %w[uid suAffiliation]) }
              .flatten
              .select { |h| Array(h['suAffiliation']).any? { |p| whitelisted_affiliations.include? p } }
              .map { |h| h['uid'] }.compact
    end

    ##
    # Get the directory information for a single user
    # @param [Hash] hash LDAP filters to use to find the user
    # @option hash [String] :uid
    # @option hash [String] :suRegID
    # @option hash [Boolean] :auth (false) whether to use authentication when querying the directory
    # @option hash [Array<String>] :fields (empty, meaning all available) list of fields to return from the directory
    def person_info(hash)
      search(default_person_info_params.merge(hash)).detect { |x| x['dn'] }
    end

    def search(hash)
      benchmark "LDAP: #{hash}" do
        filters = hash.except(:fields, :auth)

        Command.new(Settings.directory.ldapsearch.options)
               .anonymous(!hash[:auth])
               .filters(filters)
               .fields(Array(hash[:fields]))
               .exec!
      end
    end

    private

    def whitelisted_affiliations
      Settings.directory.affiliations
    end

    def logger
      Rails.logger
    end

    def default_person_info_params
      { fields: [] }
    end
  end

  ##
  # Build and execute an ldapsearch query
  class Command
    attr_reader :options

    def initialize(options = '')
      @options = options
      @filters = {}
      @fields = []
    end

    def anonymous(bool = true)
      @anonymous = bool
      self
    end

    def anonymous?
      @anonymous
    end

    def filters(filters)
      @filters.merge! filters
      self
    end

    def fields(fields)
      @fields += fields
      self
    end

    def to_s
      if Settings.directory.k5start.required && !anonymous?
        with_k5start(to_ldapsearch_s)
      else
        to_ldapsearch_s
      end
    end

    def exec!
      LdapSearch::Response.new(`#{to_s}`).to_a
    end

    private

    def to_ldapsearch_s
      ['ldapsearch', options, ('-x' if anonymous?), %("#{build_search_filter(@filters)}"), (@fields.join(' ') if @fields.any?)].compact.join(' ')
    end

    def with_k5start(str)
      %(k5start #{Settings.directory.k5start.options} -- sh -c '#{str}')
    end

    def build_search_filter(filters)
      str = filters.map do |k, v|
        next if [:auth].include? k

        if v.is_a? Array
          str = v.map do |v1|
            "(#{k}=#{v1})"
          end

          "(|#{str.join})"
        else
          "(#{k}=#{v})"
        end
      end.join

      "(&#{str})"
    end
  end
  ##
  # Parser for ldapsearch command responses
  class Response
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def to_a
      response.split("\n")
              .slice_when { |line| line =~ record_separator }
              .map do |entry|
        # we use last_key to keep track of multi-line responses
        last_key = nil

        entry.map { |line| line.split(key_separator, 2) }
             .each_with_object({}) do |(k, v), h|
          next if k.blank?

          if v.blank? && k =~ /^\s+/ && last_key
            if h[last_key].is_a? Array
              h[last_key].last << k.strip
            else
              h[last_key] += k.strip
            end
          elsif h.key?(k)
            h[k] = Array(h[k]) unless h[k].is_a?(Array)
            h[k] << v.strip if v
            last_key = k
          else
            h[k] = v.strip if v
            last_key = k
          end
        end
      end
    end

    private

    def record_separator
      /^# [0-9a-f]+, people, stanford.edu$/
    end

    def key_separator
      ': '
    end
  end
end
