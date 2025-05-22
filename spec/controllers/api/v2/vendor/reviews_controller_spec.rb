# frozen_string_literal: true

require 'spec_helper'

describe Spree::Api::V2::Vendor::ReviewsController, type: :request do
  let(:user) { create(:user) }
  let(:user_2) { create(:user) }
  let(:vendor) { create(:vendor, name: 'Test Vendor') }
  let!(:vendor_admin) { create(:vendor_user, vendor:, user:) }
  let(:product) { create(:product, vendor_id: vendor.id) }
  let(:product_2) { create(:product) }
  let!(:review) { create(:review, product:) }
  let!(:review_2) { create(:review, product: product_2) }

  before do
    allow_any_instance_of(described_class).to receive(:spree_current_user).and_return(user)
  end

  describe '#index' do
    it 'returns the reviews related to the products associated with the vendor' do
      get "/api/v2/vendor/vendors/#{vendor.id}/reviews"
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].count).to eq(1)
      expect(json_response['data'].first['id']).to eq(review.id.to_s)
    end

    it 'returns forbidden error if the user is not a vendor admin' do
      allow_any_instance_of(described_class).to receive(:spree_current_user).and_return(user_2)

      get "/api/v2/vendor/vendors/#{vendor.id}/reviews"
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status('403')
      expect(json_response['error']).to eq('You are not authorized to access this page.')
    end
  end

  describe '#show' do
    it 'returns the review' do
      get "/api/v2/vendor/vendors/#{vendor.id}/reviews/#{review.id}"
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(review.id.to_s)
    end
  end

  describe '#update' do
    it 'updates the review approval status' do
      put "/api/v2/vendor/vendors/#{vendor.id}/reviews/#{review.id}", params: { review: { approved: true } }
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['attributes']['approved']).to eq(true)
    end
  end

  describe '#destroy' do
    it 'deletes the review' do
      delete "/api/v2/vendor/vendors/#{vendor.id}/reviews/#{review.id}"
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(review.id.to_s)
    end
  end
end
