require 'rails_helper'

describe LdapSearch do
  let(:staff_user) { { 'dn' => 'xxx', 'uid' => 'staff', 'suAffiliation' => ['stanford:staff'] } }
  let(:nonstaff_user) { { 'uid' => 'nonstaff', 'suAffiliation' => ['stanford:notstaff'] } }

  before do
    # disable Parallel.map, which does not play nice with rspec mocking
    allow(Parallel).to receive(:map) do |x, &block|
      x.map(&block)
    end
  end

  describe '.in_organization' do
    before do
      a = Organization.create(admin_id: 'A')
      Organization.create!(admin_id: 'AB', parent: a)
      Organization.create!(admin_id: 'AC', parent: a)
    end

    it 'searches for all members of the organization tree' do
      expect(LdapSearch).to receive(:search).with(hash_including(suprimaryorganizationid: 'A')).and_return([])
      expect(LdapSearch).to receive(:search).with(hash_including(suprimaryorganizationid: 'AB')).and_return([])
      expect(LdapSearch).to receive(:search).with(hash_including(suprimaryorganizationid: 'AC')).and_return([])
      LdapSearch.in_organization('A')
    end

    it 'uses authenticated access to the directory' do
      expect(LdapSearch).to receive(:search).with(hash_including(auth: true)).and_return([])
      LdapSearch.in_organization('AB')
    end

    it 'filters the users based on their affiliation' do
      expect(LdapSearch).to receive(:search).with(hash_including(auth: true)).and_return([staff_user, nonstaff_user])
      expect(LdapSearch.in_organization('AB')).to match_array 'staff'
    end
  end

  describe '.person_info' do
    it 'retrieves the directory record for a single person' do
      expect(LdapSearch).to receive(:search).with(hash_including(uid: 'staff')).and_return([staff_user])
      expect(LdapSearch.person_info(uid: 'staff')).to eq staff_user
    end

    it 'ignores non-user results from the response' do
      expect(LdapSearch).to receive(:search).with(hash_including(uid: 'staff')).and_return([{ garbage: true }])
      expect(LdapSearch.person_info(uid: 'staff')).to be_nil
    end
  end

  describe LdapSearch::Response do
    subject do
      LdapSearch::Response.new(response).to_a
    end

    let(:response) do
      <<-EOR.strip_heredoc
        multiline: this is a value
          that spans multiple lines

        multivalued: 1
        multivalued: 2
        multivalued: 3

        multimulti: this is the first multi
          value, multi-line value
        multimulti: and this is the second multi
          value, multi-line value
      EOR
    end

    it 'parses multi-line values' do
      expect(subject.first['multiline']).to eq 'this is a valuethat spans multiple lines'
    end

    it 'parses multi-valued values' do
      expect(subject.first['multivalued']).to match_array %w(1 2 3)
    end

    it 'parses multi-line and -value values' do
      expect(subject.first['multimulti'].first).to eq 'this is the first multivalue, multi-line value'
      expect(subject.first['multimulti'].last).to eq 'and this is the second multivalue, multi-line value'
    end

    context 'with a multi-record response' do
      let(:response) do
        <<-EOR.strip_heredoc
          # 0001, people, stanford.edu
          uid: 0001

          # 0002, people, stanford.edu
          uid: 0002

          # 0003, people, stanford.edu
          uid: 0003
        EOR
      end

      it 'creates separate records for each person' do
        expect(subject.count(&:present?)).to eq 3
        expect(subject.reject(&:blank?).map { |x| x['uid'] }).to match_array %w(0001 0002 0003)
      end
    end
  end

  describe LdapSearch::Command do
    before do
      allow(Settings.directory.k5start).to receive(:required).and_return(false)
    end

    it 'includes the requested fields' do
      expect(described_class.new.fields(%w(a b c)).to_s).to end_with 'a b c'
    end

    describe 'filters' do
      it 'includes simple filters' do
        expect(described_class.new.filters(uid: 'a').to_s).to end_with '"(&(uid=a))"'
      end

      it 'makes multivalued requests' do
        expect(described_class.new.filters(uid: %w(a b)).to_s).to end_with '"(&(|(uid=a)(uid=b)))"'
      end

      it 'makes compound queries' do
        expect(described_class.new.filters(uid: 'a', suAffiliation: 'stanford:staff').to_s).to end_with '"(&(uid=a)(suAffiliation=stanford:staff))"'
      end
    end

    describe 'anonymous' do
      it 'builds a standard, authenticated query' do
        expect(described_class.new.anonymous(false).to_s).not_to include '-x'
      end

      it 'forces simple authentication without a username or password' do
        expect(described_class.new.anonymous(true).to_s).to include '-x'
      end
    end
  end
end
