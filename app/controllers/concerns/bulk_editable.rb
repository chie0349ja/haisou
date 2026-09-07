module BulkEditable
  extend ActiveSupport::Concern

  def bulk_update
    @bulk_records = []
    invalid = false

    bulk_edit_model.transaction do
      bulk_record_params.each do |key, attributes|
        new_record = key.to_s.start_with?("new_")
        next if new_record && bulk_blank_new_record?(attributes)

        record = new_record ? bulk_edit_model.new : bulk_edit_model.find(key)
        record.assign_attributes(attributes)
        prepare_bulk_new_record(record) if new_record
        @bulk_records << record

        invalid = true unless record.save
      end

      raise ActiveRecord::Rollback if invalid
    end

    if invalid
      instance_variable_set(:"@#{controller_name}", @bulk_records)
      prepare_bulk_index
      render :index, status: :unprocessable_content
    else
      redirect_to url_for(action: :index), notice: "一括更新しました。", status: :see_other
    end
  end

  private

  def bulk_record_params
    raw_records = params.fetch(:records, ActionController::Parameters.new)

    raw_records.each_pair.map do |key, raw_attributes|
      attributes = raw_attributes
        .permit(*bulk_edit_attributes)
        .to_h

      [ key, attributes ]
    end
  end

  def bulk_blank_new_record?(attributes)
    attributes
      .except(*bulk_ignored_blank_attributes.map(&:to_s))
      .values
      .all?(&:blank?)
  end

  def bulk_ignored_blank_attributes
    []
  end

  def prepare_bulk_new_record(_record)
  end

  def prepare_bulk_index
  end
end
