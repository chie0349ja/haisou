class CargoCategoryGroup < ApplicationRecord
  has_many :cargo_categories, dependent: :restrict_with_error
  has_many :allocation_ratios, dependent: :restrict_with_error
  has_many :delivery_records, through: :cargo_categories

  validates :name, presence: true

  scope :ordered, -> { order(:sort_order, :name) }
end
