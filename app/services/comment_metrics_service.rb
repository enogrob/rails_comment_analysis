class CommentMetricsService
  # Calculates metrics for a given user's comments and for all comments (group)
  def self.calculate_for_user(user)
    comments = Comment.where(post: user.posts)
    calculate_metrics(comments)
  end

  def self.calculate_for_group
    comments = Comment.all
    calculate_metrics(comments)
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