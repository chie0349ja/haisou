class CargoCategoryGroupsController < Admin::BaseController
  include BulkEditable

  before_action :set_cargo_category_group, only: %i[ show edit update destroy ]

  # GET /cargo_category_groups or /cargo_category_groups.json
  def index
    @cargo_category_groups = CargoCategoryGroup.ordered
    @bulk_records = @cargo_category_groups
  end

  # GET /cargo_category_groups/1 or /cargo_category_groups/1.json
  def show
  end

  # GET /cargo_category_groups/new
  def new
    @cargo_category_group = CargoCategoryGroup.new
  end

  # GET /cargo_category_groups/1/edit
  def edit
  end

  # POST /cargo_category_groups or /cargo_category_groups.json
  def create
    @cargo_category_group = CargoCategoryGroup.new(cargo_category_group_params)

    respond_to do |format|
      if @cargo_category_group.save
        format.html { redirect_to @cargo_category_group, notice: "Cargo category group was successfully created." }
        format.json { render :show, status: :created, location: @cargo_category_group }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @cargo_category_group.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /cargo_category_groups/1 or /cargo_category_groups/1.json
  def update
    respond_to do |format|
      if @cargo_category_group.update(cargo_category_group_params)
        format.html { redirect_to @cargo_category_group, notice: "Cargo category group was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @cargo_category_group }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @cargo_category_group.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /cargo_category_groups/1 or /cargo_category_groups/1.json
  def destroy
    @cargo_category_group.destroy!

    respond_to do |format|
      format.html { redirect_to cargo_category_groups_path, notice: "Cargo category group was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cargo_category_group
      @cargo_category_group = CargoCategoryGroup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cargo_category_group_params
      params.require(:cargo_category_group).permit(:name, :sort_order)
    end

    def bulk_edit_model
      CargoCategoryGroup
    end

    def bulk_edit_attributes
      %i[name sort_order]
    end

    def bulk_ignored_blank_attributes
      %i[sort_order]
    end
end
