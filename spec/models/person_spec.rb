require 'rails_helper'

describe Person do
  before do
    Rails.cache.clear

    # disable Parallel.map, which does not play nice with rspec mocking
    allow(Parallel).to receive(:map) do |x, &block|
      x.map(&block)
    end
  end

  it 'provides method access to the hash' do
    expect(Person.new(uid: 'a').uid).to eq 'a'
  end

  describe '.find' do
    it 'looks up the person by their suRegID' do
      expect(LdapSearch).to receive(:person_info).with(hash_including(suRegID: 'x'))
      Person.find('x')
    end
  end

  describe '.find_by_uid' do
    it 'looks up the person by their uid' do
      expect(LdapSearch).to receive(:person_info).with(hash_including(uid: 'abc'))
      Person.find_by_uid('abc')
    end
  end

  describe '.in_organization' do
    it 'finds all persons in a given organization' do
      expect(LdapSearch).to receive(:in_organization).with('A').and_return(%w(a b))
      expect(LdapSearch).to receive(:person_info).with(hash_including(uid: 'a')).and_return(uid: 'a', suPrimaryOrganizationID: 'A')
      expect(LdapSearch).to receive(:person_info).with(hash_including(uid: 'b')).and_return(uid: 'b', suPrimaryOrganizationID: 'A')
      allow_any_instance_of(Person).to receive(:lib_profile?)

      people = Person.in_organization('A')
      expect(people.length).to eq 2
      expect(people.map(&:id)).to match_array %w(a b)
    end

    it 'drops any person that cannot be retrieved from LDAP' do
      expect(LdapSearch).to receive(:in_organization).with('A').and_return(%w(a))
      expect(LdapSearch).to receive(:person_info).with(hash_including(uid: 'a')).and_return(nil)
      people = Person.in_organization('A')
      expect(people).to be_blank
    end
  end

  describe '#id' do
    it 'uses the suRegID if available' do
      expect(Person.new(suRegID: 'hex', uid: 'a').id).to eq 'hex'
    end

    it 'falls back on the uid' do
      expect(Person.new(uid: 'a').id).to eq 'a'
    end
  end

  describe '#suPrimaryOrganizationName' do
    it 'uses i18n to translate some organization ids' do
      expect(Person.new(suPrimaryOrganizationID: 'JYAC').suPrimaryOrganizationName).to eq 'Stanford University Press'
    end

    it 'uses the organization name in the database' do
      Organization.create(admin_id: 'AAAA', name: 'Some Org')

      expect(Person.new(suPrimaryOrganizationID: 'AAAA').suPrimaryOrganizationName).to eq 'Some Org'
    end

    it 'falls back on the ou' do
      expect(Person.new(suPrimaryOrganizationID: 'Z', ou: 'My Org').suPrimaryOrganizationName).to eq 'My Org'
    end
  end
end
