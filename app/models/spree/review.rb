class Spree::Review < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :user, class_name: Spree.user_class.to_s, optional: true
  has_many   :feedback_reviews
  has_many :images, as: :viewable, dependent: :destroy, class_name: 'Spree::ReviewImage'

  accepts_nested_attributes_for :images

  after_save :recalculate_product_rating, if: :approved?
  after_destroy :recalculate_product_rating

  validates :name, :review, presence: true
  validates :rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    message: :you_must_enter_value_for_rating
  }

  validates_associated :images
  
  default_scope { order('spree_reviews.created_at DESC') }

  scope :localized, ->(lc) { where('spree_reviews.locale = ?', lc) }
  scope :most_recent_first, -> { order('spree_reviews.created_at DESC') }
  scope :oldest_first, -> { reorder('spree_reviews.created_at ASC') }
  scope :preview, -> { limit(Spree::Reviews::Config[:preview_size]).oldest_first }
  scope :approved, -> { where(approved: true) }
  scope :not_approved, -> { where(approved: false) }
  scope :default_approval_filter, -> { Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved }
  scope :user_reviews, ->(user_id) { where('spree_reviews.user_id = ?', user_id) }

  def feedback_stars
    return 0 if feedback_reviews.size <= 0

    ((feedback_reviews.sum(:rating) / feedback_reviews.size) + 0.5).floor
  end

  def recalculate_product_rating
    product.recalculate_rating if product.present?
  end

  def self.fetch_reviews(user = nil)
    if user
      Spree::Reviews::Config[:include_unapproved_reviews] ? all : approved.or(user_reviews(user.id))
    else
      default_approval_filter
    end
  end

  def self.filter_reviews(reviews, params)
    if params[:filter] == 'pending'
      reviews.not_approved
    elsif params[:filter] == 'approved'
      reviews.approved
    else
      reviews
    end
  end

  def self.vendor_reviews(id)
    joins(:product).where(spree_products: { vendor_id: id })
  end

  def self.ransackable_attributes(auth_object = nil)
    ["approved", "created_at", "id", "id_value", "ip_address", "locale", "location", "name", "product_id", "rating", "review", "show_identifier", "title", "updated_at", "user_id", 'images']
  end
end
