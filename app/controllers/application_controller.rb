class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :authenticate!

  helper_method :current_user, :logged_in?, :current_network

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def current_network
    session[:network] || Solrengine::Rpc.configuration.network
  end

  def solana_client
    Solrengine::Rpc.client
  end

  def authenticate!
    return if logged_in?
    respond_to do |format|
      format.html { redirect_to solrengine_auth.login_path }
      format.json { render json: { error: "Not authenticated", code: "unauthenticated" }, status: :unauthorized }
    end
  end
end
