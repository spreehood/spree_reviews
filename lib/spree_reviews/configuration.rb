module SpreeReviews
  class Configuration < Spree::Preferences::Configuration
    # Include non-approved reviews in (public) listings.
    preference :include_unapproved_reviews, :boolean, default: false

    # Control how many reviews are shown in summaries etc.
    preference :preview_size, :integer, default: 3

    # Show a reviewer's email address.
    preference :show_email, :boolean, default: false

    # Show helpfullness rating form elements.
    preference :feedback_rating, :boolean, default: false

    # Require login to post reviews.
    preference :require_login, :boolean, default: true

    # Whether to keep track of the reviewer's locale.
    preference :track_locale, :boolean, default: false

    # Render checkbox for a user to approve to show their identifier
    # (name or email) on their review.
    preference :show_identifier, :boolean, default: false

    # Control how many reviews are shown on the all reviews page.
    preference :paginate_size, :integer, default: 10

    def stars
      5
    end

    def load_preferences
      stored_prefs = Spree::Preference.where("key LIKE 'spree_reviews/config/%'")
      
      stored_prefs.each do |pref|
        preference_name = pref.key.gsub('spree_reviews/config/', '')
        self[preference_name] = pref.value if respond_to?("#{preference_name}=")
      end
    end
  end
end
