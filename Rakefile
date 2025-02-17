# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

# Enhance the assets:precompile task after it's loaded
Rails.application.load_tasks

Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:dfe_frontend_images"].invoke
  Rake::Task["assets:govuk_frontend_images"].invoke
end