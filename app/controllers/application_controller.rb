class ApplicationController < ActionController::Base
  layout :determine_layout

  private

  def determine_layout
    controller_name == "categories" && action_name == "index" ? "homepage" : "other"
  end
end
