class AnalyzeController < ApplicationController
  def create
    username = params[:username]
    ImportUserDataService.new(username).call
    render json: { message: "Import started for #{username}" }, status: :accepted
  end
end