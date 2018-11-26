# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'organizations/show', type: :view do
  before(:each) do
    @organization = assign(:organization, Organization.create!(
                                            admin_id: 'Code',
                                            name: 'Name',
                                            parent_id: 1
                                          ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
  end
end
