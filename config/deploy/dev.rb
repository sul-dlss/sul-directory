server "sul-directory-dev.stanford.edu", user: fetch(:user), roles: %w{web db app}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "development"
set :bundle_without, ['test']
