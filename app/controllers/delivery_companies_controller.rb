class DeliveryCompaniesController < Admin::BaseController
  include BulkEditable

  before_action :set_delivery_company, only: %i[ show edit update destroy ]

  # GET /delivery_companies or /delivery_companies.json
  def index
    @delivery_companies = DeliveryCompany.ordered
    @bulk_records = @delivery_companies
  end

  # GET /delivery_companies/1 or /delivery_companies/1.json
  def show
  end

  # GET /delivery_companies/new
  def new
    @delivery_company = DeliveryCompany.new
  end

  # GET /delivery_companies/1/edit
  def edit
  end

  # POST /delivery_companies or /delivery_companies.json
  def create
    @delivery_company = DeliveryCompany.new(delivery_company_params)

    respond_to do |format|
      if @delivery_company.save
        format.html { redirect_to @delivery_company, notice: "Delivery company was successfully created." }
        format.json { render :show, status: :created, location: @delivery_company }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @delivery_company.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /delivery_companies/1 or /delivery_companies/1.json
  def update
    respond_to do |format|
      if @delivery_company.update(delivery_company_params)
        format.html { redirect_to @delivery_company, notice: "Delivery company was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @delivery_company }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @delivery_company.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /delivery_companies/1 or /delivery_companies/1.json
  def destroy
    @delivery_company.destroy!

    respond_to do |format|
      format.html { redirect_to delivery_companies_path, notice: "Delivery company was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_company
      @delivery_company = DeliveryCompany.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def delivery_company_params
      params.require(:delivery_company).permit(:code, :name, :active, :sort_order)
    end

    def bulk_edit_model
      DeliveryCompany
    end

    def bulk_edit_attributes
      %i[code name active sort_order]
    end

    def bulk_ignored_blank_attributes
      %i[active sort_order]
    end
end
