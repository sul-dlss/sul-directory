require 'rails_helper'

RSpec.describe "organizations/new", type: :view do
  before(:each) do
    assign(:organization, Organization.new(
      :code => "MyString",
      :level => "MyString",
      :name => "MyString",
      :parent_id => 1
    ))
  end

  it "renders new organization form" do
    render

    assert_select "form[action=?][method=?]", organizations_path, "post" do

      assert_select "input#organization_code[name=?]", "organization[code]"

      assert_select "input#organization_level[name=?]", "organization[level]"

      assert_select "input#organization_name[name=?]", "organization[name]"

      assert_select "input#organization_parent_id[name=?]", "organization[parent_id]"
    end
  end
end
