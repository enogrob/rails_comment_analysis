class CommentApprovalService
  def self.approve_or_reject(comment)
    keywords = Keyword.pluck(:word)
    count = keywords.count { |kw| comment.body.to_s.downcase.include?(kw.downcase) }
    if count >= 2
      comment.update(state: 'approved', approved: true)
    else
      comment.update(state: 'rejected', approved: false)
    end
  end
end