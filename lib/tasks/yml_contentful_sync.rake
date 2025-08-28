namespace :contentful do
  desc "Sync translations: Upload strings from yml to Contentful, delete obsolete ones, and sync back updated strings in contentful back to en.yml"
  task yml_contentful_sync: :environment do
    # Step 1: Run the task to upload new/updated translations from en.yml to Contentful
    puts "Starting step 1: Upload new/updated translations from en.yml to Contentful"
    Rake::Task["contentful:en_to_contentful_translations_create_or_update"].invoke
    puts "Step 1 completed successfully!"

    # Step 2: Run the task to delete obsolete translations in Contentful not found in en.yml
    puts "Starting step 2: Delete obsolete translations in Contentful not found in en.yml"
    Rake::Task["contentful:en_to_contentful_translations_delete"].invoke
    puts "Step 2 completed successfully!"

    # Step 3: Run the task to sync updated translations from Contentful to en.yml
    puts "Starting step 3: Sync updated translations from Contentful to en.yml"
    Rake::Task["contentful:contentful_to_en_translations_update"].invoke
    puts "Step 3 completed successfully!"

    puts "All sync tasks completed successfully!"
  rescue StandardError => e
    puts "An error occurred while running the YML-Contentful sync tasks: #{e.message}"
  end
end
