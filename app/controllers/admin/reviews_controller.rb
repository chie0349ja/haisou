module Admin
  class ReviewsController < BaseController
    REVIEWABLE_TYPES = { "client" => Client, "store" => Store }.freeze
    skip_before_action :soft_delete_master

    def index
      @pending_clients = Client.pending_review.includes(:created_by).order(:created_at)
      @pending_stores = Store.pending_review.includes(:client, :created_by).order(:created_at)
    end

    def approve
      reviewable = find_reviewable
      if reviewable.update(code: params.require(:code), pending_review: false)
        redirect_to admin_reviews_path, notice: "#{reviewable.name}を正式登録しました。"
      else
        redirect_to admin_reviews_path, alert: reviewable.errors.full_messages.to_sentence
      end
    end

    def merge
      source = find_reviewable
      target = source.class.find(params.require(:target_id))

      source.class.transaction do
        if source.is_a?(Client)
          source.delivery_records.update_all(client_id: target.id)
          source.stores.update_all(client_id: target.id)
        else
          source.delivery_records.update_all(store_id: target.id, client_id: target.client_id)
        end
        source.update!(active: false, pending_review: false)
      end

      redirect_to admin_reviews_path, notice: "#{source.name}を#{target.name}へ統合しました。"
    rescue ActiveRecord::RecordInvalid => error
      redirect_to admin_reviews_path, alert: error.record.errors.full_messages.to_sentence
    end

    private

    def find_reviewable
      REVIEWABLE_TYPES.fetch(params.require(:type)).find(params[:id])
    rescue KeyError
      raise ActiveRecord::RecordNotFound
    end
  end
end
