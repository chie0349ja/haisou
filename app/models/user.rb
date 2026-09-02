class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  enum :role, { staff: "staff", admin: "admin" }

  has_many :created_clients,
           class_name: "Client",
           foreign_key: :created_by_id,
           inverse_of: :created_by,
           dependent: :nullify
  has_many :created_stores,
           class_name: "Store",
           foreign_key: :created_by_id,
           inverse_of: :created_by,
           dependent: :nullify
  has_many :created_delivery_records,
           class_name: "DeliveryRecord",
           foreign_key: :created_by_id,
           inverse_of: :created_by,
           dependent: :nullify
  has_many :updated_delivery_records,
           class_name: "DeliveryRecord",
           foreign_key: :updated_by_id,
           inverse_of: :updated_by,
           dependent: :nullify

  validates :name, presence: true
end
