class AllocationRatiosController < Admin::BaseController
  before_action :set_allocation_ratio, only: %i[ show edit update destroy ]

  # GET /allocation_ratios or /allocation_ratios.json
  def index
    @allocation_ratios = AllocationRatio.all
  end

  # GET /allocation_ratios/1 or /allocation_ratios/1.json
  def show
  end

  # GET /allocation_ratios/new
  def new
    @allocation_ratio = AllocationRatio.new
  end

  # GET /allocation_ratios/1/edit
  def edit
  end

  # POST /allocation_ratios or /allocation_ratios.json
  def create
    @allocation_ratio = AllocationRatio.new(allocation_ratio_params)

    respond_to do |format|
      if @allocation_ratio.save
        format.html { redirect_to @allocation_ratio, notice: "Allocation ratio was successfully created." }
        format.json { render :show, status: :created, location: @allocation_ratio }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @allocation_ratio.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /allocation_ratios/1 or /allocation_ratios/1.json
  def update
    respond_to do |format|
      if @allocation_ratio.update(allocation_ratio_params)
        format.html { redirect_to @allocation_ratio, notice: "Allocation ratio was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @allocation_ratio }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @allocation_ratio.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /allocation_ratios/1 or /allocation_ratios/1.json
  def destroy
    @allocation_ratio.destroy!

    respond_to do |format|
      format.html { redirect_to allocation_ratios_path, notice: "Allocation ratio was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_allocation_ratio
      @allocation_ratio = AllocationRatio.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def allocation_ratio_params
      params.require(:allocation_ratio).permit(:cargo_category_group_id, :ratio, :effective_from, :effective_to)
    end
end
