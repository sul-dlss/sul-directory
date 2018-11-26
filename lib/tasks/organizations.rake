# frozen_string_literal: true

namespace :directory do
  desc 'Seed the database from the Stanford org chart'
  task import_org_chart: [:environment] do
    Organization.import_budget_chart!
  end
end

task 'db:seed' => 'directory:import_org_chart'
