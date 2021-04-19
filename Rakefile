# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'yard-ghpages'

Yard::GHPages::Tasks.install_tasks

Rake.add_rakelib 'lib/tasks'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
