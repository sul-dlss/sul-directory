require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  before(:each) do
    assign(:organizations, [
      Organization.create!(
        code: 'Code',
        level: 'Level',
        name: 'Name',
        parent_id: 1
      ),
      Organization.create!(
        code: 'Code',
        level: 'Level',
        name: 'Name',
        parent_id: 1
      )
    ])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: 'Code'.to_s, count: 2
    assert_select 'tr>td', text: 'Level'.to_s, count: 2
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 1.to_s, count: 2
  end
end
