namespace :assets do
  desc "Copy all DfE frontend images (DfE & GOV.UK) before asset pre-compilation"
  task copy_all_dfe_frontend_images_to_assets: :environment do
    Rake::Task["assets:dfe_frontend_images"].invoke
    Rake::Task["assets:govuk_frontend_images"].invoke
  end
end

Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:copy_all_dfe_frontend_images_to_assets"].invoke
end
