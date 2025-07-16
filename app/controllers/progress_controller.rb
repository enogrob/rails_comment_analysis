class ProgressController < ApplicationController
  def show
    # Stub: always returns 100% for now
    render json: { job_id: params[:job_id], progress: "100%" }
  end
end