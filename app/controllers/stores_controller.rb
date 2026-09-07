class StoresController < ApplicationController
  include BulkEditable

  before_action :set_store, only: %i[ show edit update destroy ]
  before_action :require_admin!, only: %i[ new create edit update destroy bulk_update ]

  # GET /stores or /stores.json
  def index
    @stores = Store.includes(:client).order(:name)
    @stores = @stores.where(client_id: params[:client_id]) if params[:client_id].present?
    @stores = @stores.search_by_name(params[:q]) if params[:q].present?
    @bulk_records = @stores
    prepare_bulk_index
  end

  def autocomplete
    stores = Store.active.order(:name)
    stores = stores.where(client_id: params[:client_id]) if params[:client_id].present?
    stores = stores.search_by_name(params[:q]) if params[:q].present?
    render json: stores.limit(10).map { |store| { id: store.id, label: store.name } }
  end

  def quick_create
    store = Store.new(
      name: params.require(:name),
      client_id: params[:client_id],
      pending_review: true,
      created_by: current_user
    )
    if store.save
      render json: { id: store.id, label: store.name }, status: :created
    else
      render json: { errors: store.errors.full_messages }, status: :unprocessable_content
    end
  end

  # GET /stores/1 or /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params.merge(created_by: current_user, pending_review: false))

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @store.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: "Store was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @store.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.destroy!

    respond_to do |format|
      format.html { redirect_to stores_path, notice: "Store was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def store_params
      params.require(:store).permit(:client_id, :code, :name, :active, :pending_review)
    end

    def bulk_edit_model
      Store
    end

    def bulk_edit_attributes
      %i[client_id code name active]
    end

    def bulk_ignored_blank_attributes
      %i[active]
    end

    def prepare_bulk_new_record(record)
      record.created_by = current_user
      record.pending_review = false
    end

    def prepare_bulk_index
      @clients = Client.order(:name)
    end

    def require_admin!
      return if current_user.admin?

      redirect_to stores_path, alert: "管理者権限が必要です。"
    end
end
