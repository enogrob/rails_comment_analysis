class AnalysisController < ApplicationController
  def create
    username = params[:username]
    job_id = AnalyzeUserWorker.perform_async(username)
    render json: { job_id: job_id, message: "Analysis started for #{username}" }, status: :accepted
  end
end