require 'rails_helper'

RSpec.describe Comment, type: :model do
  let!(:user) { User.create!(username: 'TestUser', external_id: 1) }
  let!(:post) { Post.create!(user: user, external_id: 1, title: 'Test', body: 'Test') }
  let!(:comment) { Comment.create!(post: post, external_id: 1, body: 'foo bar', state: 'new') }

  it 'belongs to post' do
    expect(comment.post).to eq(post)
  end

  it 'transitions state with aasm' do
    expect(comment.state).to eq('new')
    comment.process!
    expect(comment.state).to eq('processing')
    comment.approve!
    expect(comment.state).to eq('approved')
  end
end