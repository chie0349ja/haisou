class AllocationRatio < ApplicationRecord
  belongs_to :cargo_category_group

  validates :ratio, :effective_from, presence: true
  validates :ratio,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1
            },
            allow_nil: true
  validate :effective_period_must_be_valid
  validate :effective_period_must_not_overlap

  private

  def effective_period_must_be_valid
    return if effective_from.blank? || effective_to.blank?
    return if effective_to >= effective_from

    errors.add(:effective_to, "は適用開始日以降の日付にしてください")
  end

  def effective_period_must_not_overlap
    return if cargo_category_group.blank? || effective_from.blank?
    return if effective_to.present? && effective_to < effective_from

    overlapping = cargo_category_group.allocation_ratios
    overlapping = overlapping.where.not(id: id) if persisted?
    overlapping = overlapping.where("effective_from <= ?", effective_to) if effective_to.present?
    overlapping = overlapping.where(
      "effective_to IS NULL OR effective_to >= ?",
      effective_from
    )

    return unless overlapping.exists?

    errors.add(:base, "同じグループの適用期間が既存の按分比率と重複しています")
  end
end
