class WebhooksController < ApplicationController
  respond_to :html, :json
  before_action :authenticate_user!, only: :index
  skip_before_action :verify_authenticity_token, only: :create

  def index
  end

  def create
    if ping_request?
      hook = Hook.create!(ping_params)
      respond_with hook, location: root_path
    end
  end

  private

  def ping_params
    permitted = params.require(:hook).permit(:type, :name, :active, :url, :id)
    permitted[:external_id] = permitted.delete(:id)
    permitted[:hook_type] = permitted.delete(:type)
    permitted
  end

  def ping_request?
    params.include?(:zen)
  end
end
