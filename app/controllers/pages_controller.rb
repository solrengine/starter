class PagesController < ApplicationController
  skip_before_action :authenticate!

  def home
    redirect_to dashboard_path if logged_in?
  end
end
