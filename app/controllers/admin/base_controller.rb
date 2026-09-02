module Admin
  class BaseController < ApplicationController
    before_action :require_admin!
    before_action :soft_delete_master, only: :destroy

    private

    def require_admin!
      return if current_user&.admin?

      redirect_to root_path, alert: "管理者権限が必要です。"
    end

    def soft_delete_master
      model_class = controller_name.classify.constantize
      return unless model_class.column_names.include?("active")

      model_class.find(params[:id]).update!(active: false)
      redirect_to url_for(action: :index), notice: "無効化しました。", status: :see_other
    end
  end
end
