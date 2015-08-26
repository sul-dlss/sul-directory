class Organization < ActiveRecord::Base
  belongs_to :parent, class_name: 'Organization'
  has_many :children, foreign_key: 'parent_id', class_name: 'Organization'

  class << self
    def in_tree(parent)
      ids = []
      new_ids = Array.wrap(parent)

      loop do
        break if new_ids.empty?
        tmp = []
        new_ids.each do |p|
          tmp += p.children.to_a
        end

        ids += new_ids
        new_ids = tmp.flatten
      end

      where(id: ids)
    end

    def import_budget_chart!
      organizations.each do |sorg|
        org = Organization.find_or_initialize_by(admin_id: sorg[:admin_id])
        org.update(name: sorg[:name])
        org.parent = Organization.find_by(admin_id: sorg[:parent]) if sorg[:parent]

        org.save
      end
    end

    private

    def organizations
      budget_orgchart.xpath('//child').map do |x|
        { admin_id: x.xpath('@adminid').text, name: x.xpath('@name').text.strip, parent: x.xpath('../@adminid').text }
      end
    end

    def budget_orgchart
      url = 'http://registry.stanford.edu/reference/OrgTreeAdministrative.xml'
      response = Hurley.get(url)
      Nokogiri::XML(response.body)
    end
  end
end
