class AnalysisController < ApplicationController
  def create
    username = params[:username]
    if username.blank?
      render json: { error: 'Missing username' }, status: :bad_request
      return
    end
    job_id = AnalyzeUserWorker.perform_async(username)
    render json: { job_id: job_id, message: "Analysis started for #{username}" }, status: :accepted
  end
end