require 'rails_helper'

RSpec.describe 'organizations/index', type: :view do
  before(:each) do
    assign(:organizations, [
      Organization.create!(
        admin_id: 'Code A',
        name: 'Name',
        parent_id: 1
      ),
      Organization.create!(
        admin_id: 'Code B',
        name: 'Name',
        parent_id: 1
      )
    ])
  end

  it 'renders a list of organizations' do
    render
    assert_select 'tr>td', text: 'Code A'.to_s, count: 1
    assert_select 'tr>td', text: 'Code B'.to_s, count: 1
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
    assert_select 'tr>td', text: 1.to_s, count: 2
  end
end
