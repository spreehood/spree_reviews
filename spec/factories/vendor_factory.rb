# frozen_string_literal: true

FactoryBot.define do
  factory :vendor, class: Spree::Vendor do
    name { Faker::Company.name }
    about_us { 'About us...' }
    contact_us { 'Contact us...' }

    factory :active_vendor do
      name { 'Active vendor' }
      state { :active }
    end
  end

  factory :vendor_user, class: Spree::VendorUser do
    user
    vendor
  end
end
