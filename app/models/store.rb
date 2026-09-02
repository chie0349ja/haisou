class Store < ApplicationRecord
  belongs_to :client, optional: true
  belongs_to :created_by,
             class_name: "User",
             inverse_of: :created_stores,
             optional: true

  has_many :delivery_records, dependent: :restrict_with_error

  include PgSearch::Model

  validates :name, presence: true
  validates :code, uniqueness: true, allow_blank: true
  validates :code, presence: true, if: -> { active? && !pending_review? }

  scope :active, -> { where(active: true) }
  scope :pending_review, -> { where(pending_review: true) }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: { trigram: { threshold: 0.3 } }
end
