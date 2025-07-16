class AnalysisController < ApplicationController
  # POST /analyze
  def create
    username = params[:username]
    user = User.find_by(username: username)
    unless user
      ImportUserDataService.new(username).call
      user = User.find_by(username: username)
    end

    if user
      user_metrics = CommentMetricsService.calculate_for_user(user)
      group_metrics = CommentMetricsService.calculate_for_group

      render json: {
        user: username,
        user_metrics: user_metrics,
        group_metrics: group_metrics
      }, status: :ok
    else
      render json: { error: "User not found or could not be imported." }, status: :not_found
    end
  end
end