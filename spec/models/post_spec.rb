require 'rails_helper'

RSpec.describe Post, type: :model do
  let!(:user) { User.create!(username: 'TestUser', external_id: 1) }
  let!(:post) { Post.create!(user: user, external_id: 1, title: 'Test', body: 'Test') }
  let!(:comment) { Comment.create!(post: post, external_id: 1, body: 'foo bar') }

  it 'belongs to user' do
    expect(post.user).to eq(user)
  end

  it 'has many comments' do
    expect(post.comments).to include(comment)
  end
end