
require 'spree'
require 'spree_extension'
require 'spree_reviews/configuration'
require 'spree_reviews/engine'
require 'spree_reviews/version'

module SpreeReviews
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end
end