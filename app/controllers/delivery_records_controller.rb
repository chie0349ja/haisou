class DeliveryRecordsController < ApplicationController
  before_action :set_delivery_record, only: %i[ show edit update destroy ]
  before_action :load_form_options, only: %i[ new create edit update ]

  # GET /delivery_records or /delivery_records.json
  def index
    @delivery_records = DeliveryRecord.includes(
      :course, :delivery_company, :vehicle, :driver, :cargo_category, :client, :store, :unit
    ).order(service_date: :desc, departure_at: :desc)
    @delivery_records = @delivery_records.where(service_date: params[:service_date]) if params[:service_date].present?
    @delivery_records = @delivery_records.where(course_id: params[:course_id]) if params[:course_id].present?
    @delivery_records = @delivery_records.where(client_id: params[:client_id]) if params[:client_id].present?
  end

  # GET /delivery_records/1 or /delivery_records/1.json
  def show
  end

  # GET /delivery_records/new
  def new
    @delivery_record = DeliveryRecord.new(
      service_date: Date.current,
      departure_at: Time.current.change(sec: 0)
    )
  end

  # GET /delivery_records/1/edit
  def edit
  end

  # POST /delivery_records or /delivery_records.json
  def create
    @delivery_record = DeliveryRecord.new(delivery_record_params.merge(created_by: current_user, updated_by: current_user))

    respond_to do |format|
      if @delivery_record.save
        format.html { redirect_to @delivery_record, notice: "Delivery record was successfully created." }
        format.json { render :show, status: :created, location: @delivery_record }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @delivery_record.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /delivery_records/1 or /delivery_records/1.json
  def update
    respond_to do |format|
      if @delivery_record.update(delivery_record_params.merge(updated_by: current_user))
        format.html { redirect_to @delivery_record, notice: "Delivery record was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @delivery_record }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @delivery_record.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /delivery_records/1 or /delivery_records/1.json
  def destroy
    @delivery_record.destroy!

    respond_to do |format|
      format.html { redirect_to delivery_records_path, notice: "Delivery record was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_record
      @delivery_record = DeliveryRecord.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def delivery_record_params
      params.require(:delivery_record).permit(
        :service_date, :course_id, :delivery_company_id, :vehicle_id, :driver_id,
        :cargo_category_id, :client_id, :store_id, :volume, :unit_id,
        :departure_at, :arrival_at
      )
    end

    def load_form_options
      @courses = Course.active.ordered
      @delivery_companies = DeliveryCompany.active.ordered
      @vehicles = Vehicle.active.ordered
      @drivers = Driver.active.ordered
      @cargo_categories = CargoCategory.active.ordered
      @units = Unit.active.ordered
    end
end
