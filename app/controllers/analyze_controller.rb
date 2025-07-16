class AnalyzeController < ApplicationController
  def create
    username = params[:username]
    if username.blank?
      render json: { error: 'Missing username' }, status: :bad_request
      return
    end
    ImportUserDataService.new(username).call
    job_id = SecureRandom.uuid # Simulate a job_id for legacy endpoint
    render json: { job_id: job_id, message: "Import started for #{username}" }, status: :accepted
  end
end