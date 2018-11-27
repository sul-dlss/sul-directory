# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/new', type: :view do
  before(:each) do
    assign(:organization, Organization.new(
                            admin_id: 'MyString',
                            name: 'MyString',
                            parent_id: 1
                          ))
  end

  it 'renders new organization form' do
    render

    assert_select 'form[action=?][method=?]', organizations_path, 'post' do
      assert_select 'input#organization_admin_id[name=?]', 'organization[admin_id]'

      assert_select 'input#organization_name[name=?]', 'organization[name]'

      assert_select 'input#organization_parent_id[name=?]', 'organization[parent_id]'
    end
  end
end
