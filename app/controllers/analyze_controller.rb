class AnalyzeController < ApplicationController
  def create
    username = params[:username]
    if username.blank?
      render json: { error: 'Missing username' }, status: :bad_request
      return
    end
    ImportUserDataService.new(username).call
    render json: { message: "Import started for #{username}" }, status: :accepted
  end
end