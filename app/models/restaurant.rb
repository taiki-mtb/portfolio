class Restaurant < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :category
  default_scope -> { order(created_at: :desc) }
  mount_uploaders :images, PictureUploader
  validates :name, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 140 }
  validate  :picture_size
  geocoded_by :city_address
  after_validation :geocode, if: :city_address_changed?

  def feed_comment(restaurant_id)
    Comment.where("restaurant_id = ?", restaurant_id)
  end

  private

    def picture_size
      if images.size > 5.megabytes
        errors.add(:images, "：5MBより大きい画像はアップロードできません。")
      end
    end
end
