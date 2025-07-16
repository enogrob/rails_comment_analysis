class ImportUserDataService
  include HTTParty
  base_uri 'https://jsonplaceholder.typicode.com'

  def initialize(username)
    @username = username
  end

  def call
    user = fetch_user
    return unless user

    user_record = User.find_or_create_by(username: user['username'], external_id: user['id'])
    posts = fetch_posts(user['id'])
    posts.each do |post|
      post_record = Post.find_or_create_by(user: user_record, external_id: post['id'], title: post['title'], body: post['body'])
      comments = fetch_comments(post['id'])
      comments.each do |comment|
        translated = TranslateService.translate(comment['body'])
        comment_record = Comment.find_or_create_by(
          post: post_record, 
          external_id: comment['id'], 
          body: comment['body'], 
          translated_body: translated,
          state: 'new'
        )
        CommentApprovalService.approve_or_reject(comment_record)
      end
    end
  end

  private

  def fetch_user
    response = self.class.get("/users", query: { username: @username })
    response.parsed_response.first
  end

  def fetch_posts(user_id)
    response = self.class.get("/posts", query: { userId: user_id })
    response.parsed_response
  end

  def fetch_comments(post_id)
    response = self.class.get("/comments", query: { postId: post_id })
    response.parsed_response
  end
end