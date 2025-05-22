module Spree
  module Api
    module V2
      module Storefront
        class FeedbackReviewsController < ::Spree::Api::V2::ResourceController
          before_action :load_review, only: :create
          before_action :require_spree_current_user if Spree::Reviews::Config[:require_login]

          def create
            if @review.present?
              @feedback_review = @review.feedback_reviews.new(feedback_review_params)
              @feedback_review.user = spree_current_user

              # TODO: check if it is right to let user disable track_locale, there has been some new changes in recent
              # spree regarding locale and we want to ensure we don't break reviews features in newer spree projects

              @feedback_review.locale = I18n.locale.to_s if Spree::Reviews::Config[:track_locale]
              @feedback_review.save
            end

            render_serialized_payload { serialize_resource(@feedback_review) }
          end

          def update
            feedback_review = Spree::FeedbackReview.find(params[:id])

            if feedback_review.user == spree_current_user && feedback_review.update(feedback_review_params)
              render_serialized_payload { serialize_resource(feedback_review) }
            else
              render_error_payload(feedback_review.errors)
            end
          end

          def destroy
            feedback_review = Spree::FeedbackReview.find(params[:id])

            if feedback_review.user == spree_current_user && feedback_review.destroy
              render_serialized_payload { serialize_resource(feedback_review) }
            else
              render_error_payload(feedback_review.errors)
            end
          end

          private

          def scope
            Spree::FeedbackReview
          end

          def load_review
            @review ||= Spree::Review.find_by_id!(params[:review_id])
          end

          def feedback_review_params
            params.require(:feedback_review).permit(permitted_feedback_review_attributes)
          end

          def permitted_feedback_review_attributes
            permitted_attributes.feedback_review_attributes
          end

          def paginated_collection
            collection_paginator.new(collection, params).call
          end

          def collection_serializer
            Spree::V2::Storefront::FeedbackReviewSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::FeedbackReviewSerializer
          end
        end
      end
    end
  end
end
