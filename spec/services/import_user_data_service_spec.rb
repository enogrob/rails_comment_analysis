require 'rails_helper'

describe ImportUserDataService do
  let(:username) { 'TestUser' }
  let(:user_id) { 42 }
  let(:post_id) { 100 }
  let(:comment_id) { 200 }

  before do
    # Mock HTTParty requests
    allow(ImportUserDataService).to receive(:get).with('/users', hash_including(query: { username: username })).and_return(
      double(parsed_response: [{ 'id' => user_id, 'username' => username }])
    )
    allow(ImportUserDataService).to receive(:get).with('/posts', hash_including(query: { userId: user_id })).and_return(
      double(parsed_response: [{ 'id' => post_id, 'title' => 'PostTitle', 'body' => 'PostBody' }])
    )
    allow(ImportUserDataService).to receive(:get).with('/comments', hash_including(query: { postId: post_id })).and_return(
      double(parsed_response: [{ 'id' => comment_id, 'body' => 'CommentBody' }])
    )
    allow(TranslateService).to receive(:translate).and_return('[PT] CommentBody')
    $redis.flushdb if defined?($redis)
  end

  it 'imports user, post, and comment, and translates comment' do
    expect {
      described_class.new(username).call
    }.to change(User, :count).by(1)
     .and change(Post, :count).by(1)
     .and change(Comment, :count).by(1)

    user = User.find_by(username: username)
    post = Post.find_by(user: user)
    comment = Comment.find_by(post: post)

    expect(user.external_id).to eq(user_id)
    expect(post.external_id).to eq(post_id)
    expect(comment.external_id).to eq(comment_id)
    expect(comment.translated_body).to eq('[PT] CommentBody')
  end

  it 'calls CommentApprovalService for each comment' do
    expect(CommentApprovalService).to receive(:approve_or_reject).at_least(:once)
    described_class.new(username).call
  end

  it 'returns nil if user not found' do
    allow(ImportUserDataService).to receive(:get).with('/users', hash_including(query: { username: 'none' })).and_return(
      double(parsed_response: [])
    )
    expect(described_class.new('none').call).to be_nil
  end
end
