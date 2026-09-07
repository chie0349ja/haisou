class ClientsController < ApplicationController
  include BulkEditable

  before_action :set_client, only: %i[ show edit update destroy ]
  before_action :require_admin!, only: %i[ new create edit update destroy bulk_update ]

  # GET /clients or /clients.json
  def index
    @clients = Client.order(:name)
    @clients = @clients.search_by_name(params[:q]) if params[:q].present?
    @bulk_records = @clients
  end

  def autocomplete
    clients = Client.active.order(:name)
    clients = clients.search_by_name(params[:q]) if params[:q].present?
    render json: clients.limit(10).map { |client| { id: client.id, label: client.name } }
  end

  def quick_create
    client = Client.new(name: params.require(:name), pending_review: true, created_by: current_user)
    if client.save
      render json: { id: client.id, label: client.name }, status: :created
    else
      render json: { errors: client.errors.full_messages }, status: :unprocessable_content
    end
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params.merge(created_by: current_user, pending_review: false))

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @client.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: "Client was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @client.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to clients_path, notice: "Client was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:code, :name, :active, :pending_review)
    end

    def bulk_edit_model
      Client
    end

    def bulk_edit_attributes
      %i[code name active]
    end

    def bulk_ignored_blank_attributes
      %i[active]
    end

    def prepare_bulk_new_record(record)
      record.created_by = current_user
      record.pending_review = false
    end

    def require_admin!
      return if current_user.admin?

      redirect_to clients_path, alert: "管理者権限が必要です。"
    end
end
