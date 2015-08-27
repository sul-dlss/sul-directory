require 'rails_helper'

describe Person do
  before do
    Rails.cache.clear
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

  describe '#id' do
    it 'uses the suRegID if available' do
      expect(Person.new(suRegID: 'hex', uid: 'a').id).to eq 'hex'
    end

    it 'falls back on the uid' do
      expect(Person.new(uid: 'a').id).to eq 'a'
    end
  end
end
