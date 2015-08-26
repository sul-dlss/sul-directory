class DirectoryController < ApplicationController
  after_action :allow_iframes

  def index
    org_code = Settings.directory.org_code

    @people = Person.in_organization(org_code).sort_by(&:suDisplayNameLF)

    respond_to do |format|
      format.html
      format.xml
    end
  end

  private

  def allow_iframes
    response.headers.except! 'X-Frame-Options'
  end
end
