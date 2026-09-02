class DeliveryRecord < ApplicationRecord
  belongs_to :course
  belongs_to :delivery_company
  belongs_to :vehicle
  belongs_to :driver
  belongs_to :cargo_category
  belongs_to :client
  belongs_to :store, optional: true
  belongs_to :unit
  belongs_to :created_by,
             class_name: "User",
             inverse_of: :created_delivery_records,
             optional: true
  belongs_to :updated_by,
             class_name: "User",
             inverse_of: :updated_delivery_records,
             optional: true

  validates :service_date, :course, :delivery_company, :vehicle, :driver,
            :cargo_category, :client, :unit, :volume, :departure_at,
            presence: true
  validates :volume, numericality: { greater_than: 0 }, allow_nil: true
  validate :arrival_must_not_precede_departure
  validate :store_must_belong_to_client
  validate :vehicle_must_belong_to_delivery_company
  validate :driver_must_belong_to_delivery_company

  def overnight?
    departure_at.present? && arrival_at.present? &&
      arrival_at.to_date > departure_at.to_date
  end

  private

  def arrival_must_not_precede_departure
    return if departure_at.blank? || arrival_at.blank?
    return if arrival_at >= departure_at

    errors.add(:arrival_at, "must be on or after departure time")
  end

  def store_must_belong_to_client
    return if store.blank? || client.blank?
    return if store.client_id == client_id

    errors.add(:store, "must belong to the selected client")
  end

  def vehicle_must_belong_to_delivery_company
    return if vehicle.blank? || delivery_company.blank?
    return if vehicle.delivery_company_id.blank?
    return if vehicle.delivery_company_id == delivery_company_id

    errors.add(:vehicle, "must belong to the selected delivery company")
  end

  def driver_must_belong_to_delivery_company
    return if driver.blank? || delivery_company.blank?
    return if driver.delivery_company_id.blank?
    return if driver.delivery_company_id == delivery_company_id

    errors.add(:driver, "must belong to the selected delivery company")
  end
end
