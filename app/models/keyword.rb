class Keyword < ApplicationRecord
  validates :word, presence: true
  after_commit :invalidate_metrics_cache_and_reprocess_comments

  private

  def invalidate_metrics_cache_and_reprocess_comments
    # Invalidate metrics cache
    $redis.del("group_metrics")
    User.find_each { |user| $redis.del("user_metrics:#{user.id}") }

    # Reprocess all comments for approval
    Comment.find_each do |comment|
      CommentApprovalService.approve_or_reject(comment)
    end
  end
end
