set :stages, %w(staging prod)
set :default_stage, "staging"
require 'capistrano/ext/multistage'