class AnalyzeUserWorker
  include Sidekiq::Worker

  def perform(username)
    ImportUserDataService.new(username).call
    user = User.find_by(username: username)
    if user
      user_metrics = CommentMetricsService.calculate_for_user(user)
      group_metrics = CommentMetricsService.calculate_for_group
      # Optionally: store metrics in cache or DB for progress endpoint
    end
  end
end