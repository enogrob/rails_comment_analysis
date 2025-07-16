class Keyword < ApplicationRecord
  after_commit :invalidate_metrics_cache

  private

  def invalidate_metrics_cache
    $redis.del("group_metrics")
    User.find_each { |user| $redis.del("user_metrics:#{user.id}") }
  end
end
