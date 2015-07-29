class DirectoryController < ApplicationController
  def index
    org_code = Rails.application.config.root_org_code

    @people = Rails.cache.fetch("people/#{org_code}", expires_in: 24.hours) do
      Person.in_organization(org_code).sort_by(&:suDisplayNameLF)
    end

    respond_to do |format|
      format.html
      format.xml
    end
  end
end
