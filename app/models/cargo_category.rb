class CargoCategory < ApplicationRecord
  belongs_to :cargo_category_group

  has_many :delivery_records, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, uniqueness: true, allow_blank: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:sort_order, :name) }
end
