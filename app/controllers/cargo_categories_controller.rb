class CargoCategoriesController < Admin::BaseController
  before_action :set_cargo_category, only: %i[ show edit update destroy ]

  # GET /cargo_categories or /cargo_categories.json
  def index
    @cargo_categories = CargoCategory.all
  end

  # GET /cargo_categories/1 or /cargo_categories/1.json
  def show
  end

  # GET /cargo_categories/new
  def new
    @cargo_category = CargoCategory.new
  end

  # GET /cargo_categories/1/edit
  def edit
  end

  # POST /cargo_categories or /cargo_categories.json
  def create
    @cargo_category = CargoCategory.new(cargo_category_params)

    respond_to do |format|
      if @cargo_category.save
        format.html { redirect_to @cargo_category, notice: "Cargo category was successfully created." }
        format.json { render :show, status: :created, location: @cargo_category }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @cargo_category.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cargo_categories/1 or /cargo_categories/1.json
  def update
    respond_to do |format|
      if @cargo_category.update(cargo_category_params)
        format.html { redirect_to @cargo_category, notice: "Cargo category was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @cargo_category }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @cargo_category.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /cargo_categories/1 or /cargo_categories/1.json
  def destroy
    @cargo_category.destroy!

    respond_to do |format|
      format.html { redirect_to cargo_categories_path, notice: "Cargo category was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cargo_category
      @cargo_category = CargoCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cargo_category_params
      params.require(:cargo_category).permit(:code, :name, :cargo_category_group_id, :active, :sort_order)
    end
end
