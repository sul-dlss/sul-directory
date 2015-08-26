##
# Main staff directory controller
class DirectoryController < ApplicationController
  after_action :allow_iframes
  before_action :load_people

  def index
    respond_to do |format|
      format.html
      format.xml
    end
  end

  private

  def load_people
    org_code = Settings.directory.org_code

    @people = Person.in_organization(org_code).sort_by(&:suDisplayNameLF)
  end

  def allow_iframes
    response.headers.except! 'X-Frame-Options'
  end
end
