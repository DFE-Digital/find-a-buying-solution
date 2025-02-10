# This Rake task copies images from external (/node_modules) frontend packages (DfE & GOV.UK Frontend)
# into the Rails app's assets directory. This ensures that the images are available
# for use in the application, especially in production where asset pipelines are used.
#
# Usage:
#   - Run manually: `rake assets:copy_dfe_frontend_images`
#   - Run manually: `rake assets:copy_govuk_frontend_images`
#   - Can be configured to run automatically before asset precompilation.

namespace :assets do
  desc "Copy DfE Frontend images to Rails.root.join('app','assets','images','dfe-frontend')"
  # node_modules/dfe-frontend/packages/assets
  task dfe_frontend_images: :environment do
    source = Rails.root.join("node_modules/dfe-frontend/packages/assets")
    destination = Rails.root.join("app/assets/images/dfe-frontend")
    puts "Source path: #{source}"
    puts "Destination path: #{destination}"
    FileUtils.mkdir_p(destination)
    FileUtils.cp_r("#{source}/.", destination.to_s)
    puts "DfE Frontend images have been successfully copied to #{destination}"
  end

  desc "Copy Govuk Frontend images to Rails.root.join('app','assets','images','govuk-frontend')"
  # node_modules/govuk-frontend/dist/govuk/assets/images
  task gov_frontend_images: :environment do
    source = Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets/images")
    destination = Rails.root.join("app/assets/images/govuk-frontend")
    puts "Source path: #{source}"
    puts "Destination path: #{destination}"
    FileUtils.mkdir_p(destination)
    FileUtils.cp_r("#{source}/.", destination.to_s)
    puts "Govuk Frontend images have been successfully copied to #{destination}"
  end
end
