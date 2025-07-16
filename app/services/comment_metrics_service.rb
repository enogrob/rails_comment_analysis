class CommentMetricsService
  CACHE_TTL = 10.minutes

  # Calculates metrics for a given user's comments and for all comments (group)
  def self.calculate_for_user(user)
    cache_key = "user_metrics:#{user.id}"
    cached = $redis.get(cache_key)
    return JSON.parse(cached) if cached

    comments = Comment.where(post: user.posts)
    metrics = calculate_metrics(comments)
    $redis.set(cache_key, metrics.to_json, ex: CACHE_TTL)
    metrics
  end

  def self.calculate_for_group
    cache_key = "group_metrics"
    cached = $redis.get(cache_key)
    return JSON.parse(cached) if cached

    comments = Comment.all
    metrics = calculate_metrics(comments)
    $redis.set(cache_key, metrics.to_json, ex: CACHE_TTL)
    metrics
  end

  # Calculates mean, median, and standard deviation for comment body lengths
  def self.calculate_metrics(comments)
    lengths = comments.map { |c| c.body.to_s.length }
    return { mean: 0, median: 0, stddev: 0 } if lengths.empty?

    mean = lengths.sum.to_f / lengths.size
    sorted = lengths.sort
    median = sorted.length.odd? ? sorted[sorted.length / 2] : (sorted[sorted.length / 2 - 1] + sorted[sorted.length / 2]) / 2.0
    variance = lengths.map { |l| (l - mean) ** 2 }.sum / lengths.size
    stddev = Math.sqrt(variance)

    {
      mean: mean.round(2),
      median: median.round(2),
      stddev: stddev.round(2),
      count: lengths.size
    }
  end
end