class Client < ApplicationRecord
  include PgSearch::Model

  belongs_to :created_by,
             class_name: "User",
             inverse_of: :created_clients,
             optional: true

  has_many :stores, dependent: :restrict_with_error
  has_many :delivery_records, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, uniqueness: true, allow_blank: true
  validates :code, presence: true, if: -> { active? && !pending_review? }

  scope :active, -> { where(active: true) }
  scope :pending_review, -> { where(pending_review: true) }

  pg_search_scope :search_by_name,
                  against: :name,
                  using: { trigram: { threshold: 0.3 } }
end
