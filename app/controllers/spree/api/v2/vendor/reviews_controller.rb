# frozen_string_literal: true

module Spree
  module Api
    module V2
      module Vendor
        class ReviewsController < ResourceController
          before_action :load_vendor
          before_action :require_vendor_access

          # GET /api/v2/vendor/vendors/:vendor_id/reviews
          def index
            render_serialized_payload { serialize_collection(paginated_collection) }
          end

          # GET /api/v2/vendor/vendors/:vendor_id/reviews/:id
          def show
            review = resource.find(params[:id])

            if review
              render_serialized_payload { serialize_resource(review) }
            else
              render_error_payload(review.errors)
            end
          end

          # PUT/PATCH /api/v2/vendor/vendors/:vendor_id/reviews/:id
          def update
            review = resource.find(params[:id])

            if review.update(review_params)
              render_serialized_payload { serialize_resource(review) }
            else
              render_error_payload(review.errors)
            end
          end

          # DELETE /api/v2/vendor/vendors/:vendor_id/reviews/:id
          def destroy
            review = resource.find(params[:id])

            if review.destroy
              render_serialized_payload { serialize_resource(review) }
            else
              render_error_payload(review.errors)
            end
          end

          private

          def paginated_collection
            collection_paginator.new(resource, params).call
          end

          def collection_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::ReviewSerializer
          end

          def review_params
            params.require(:review).permit(:approved)
          end

          def resource
            Spree::Review.vendor_reviews(@vendor.id)
          end

          def load_vendor
            @vendor = Spree::Vendor.friendly.find(params[:vendor_id])
          end

          def require_vendor_access
            raise CanCan::AccessDenied unless @vendor.users.include?(spree_current_user)
          end
        end
      end
    end
  end
end
