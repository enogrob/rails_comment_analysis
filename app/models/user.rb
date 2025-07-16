class User < ApplicationRecord
  has_many :posts

  after_commit :invalidate_metrics_cache

  private

  def invalidate_metrics_cache
    $redis.del("user_metrics:#{self.id}")
    $redis.del("group_metrics")
  end
end
