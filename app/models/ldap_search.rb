class LdapSearch
  class <<self
    include ActiveSupport::Benchmarkable

    def in_organization(admin_id)
      Organization.in_tree(Organization.find_by(admin_id: admin_id)).pluck(:admin_id).map do |id|
        search(suprimaryorganizationid: id, auth: true, fields: %w(uid suAffiliation))
      end.flatten
        .select { |h| Array(h['suAffiliation']).any? { |p| whitelisted_affiliations.include? p }  }
        .map { |h| h['uid'] }.compact
    end

    def person_info(hash)
      search(hash.merge(fields: [])).detect { |x| x['dn'] }
    end

    private

    def build_search_filter(filters)
      str = filters.map do |k, v|
        next if [:auth, :fields].include? k

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

    def search(hash)
      filter = build_search_filter(hash)

      response = benchmark "LDAP: #{filter}" do
        ldapsearch_cmd = %(ldapsearch #{Settings.directory.ldapsearch.options} #{'-x' unless hash[:auth]} "#{filter}" #{Array(hash[:fields]).join(' ')})
        if hash[:auth] && Settings.directory.k5start.required
          `k5start #{Settings.directory.k5start.options} -- sh -c '#{ldapsearch_cmd}'`
        else
          `#{ldapsearch_cmd}`
        end
      end

      response.split("\n")
        .slice_when { |line| line =~ /^# [0-9a-f]+, people, stanford.edu$/ }
        .map do |entry|
          last_key = nil

          entry.map { |line| line.split(': ', 2) }
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

    def whitelisted_affiliations
      Settings.directory.affiliations
    end

    def logger
      Rails.logger
    end
  end
end
