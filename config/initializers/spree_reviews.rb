Rails.application.config.after_initialize do
  begin
    if defined?(Spree::Preference) && ActiveRecord::Base.connection.table_exists?(:spree_preferences)
      SpreeReviews::Config.load_preferences
    end
  rescue StandardError => e
    Rails.logger.error "Error loading SpreeReviews preferences: #{e.message}"
  end
end