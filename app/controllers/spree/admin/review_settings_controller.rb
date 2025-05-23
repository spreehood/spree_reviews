module Spree
  module Admin
    class ReviewSettingsController < Spree::Admin::BaseController
      def update
        preference_params.each do |name, value|
          integer_prefs = [:preview_size, :paginate_size]
          
          if integer_prefs.include?(name.to_sym)
            value = value.to_i
          else
            value = ActiveModel::Type::Boolean.new.cast(value)
          end
          
          # Directly save to the preference store with a Spree-standard key format
          preference_key = "spree_reviews/config/#{name}"
          Spree::Preference.where(key: preference_key).destroy_all
          Spree::Preference.create(key: preference_key, value: value)
          
          # Also update the runtime config to make it available immediately
          SpreeReviews::Config[name] = value if SpreeReviews::Config.respond_to?("#{name}=")
        end

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:review_settings, scope: :spree_reviews))
        redirect_to edit_admin_review_settings_path
      end

      private

      def preference_params
        params.permit(
          :include_unapproved_reviews,
          :feedback_rating,
          :show_email,
          :require_login,
          :track_locale,
          :show_identifier,
          :preview_size,
          :paginate_size
        )
      end
    end
  end
end
