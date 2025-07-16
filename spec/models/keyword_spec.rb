require 'rails_helper'

RSpec.describe Keyword, type: :model do
  let!(:user) { User.create!(username: 'TestUser', external_id: 1) }
  let!(:post) { Post.create!(user: user, external_id: 1, title: 'Test', body: 'Test') }
  let!(:comment) { Comment.create!(post: post, external_id: 1, body: 'foo bar', state: 'new', approved: nil) }

  before do
    # Clear redis cache before each test
    $redis.del("group_metrics")
    $redis.del("user_metrics:#{user.id}")
  end

  it 'invalidates metrics cache on keyword change' do
    # Set cache
    $redis.set("group_metrics", {foo: 1}.to_json)
    $redis.set("user_metrics:#{user.id}", {bar: 2}.to_json)
    expect($redis.get("group_metrics")).not_to be_nil
    expect($redis.get("user_metrics:#{user.id}")).not_to be_nil
    # Trigger after_commit
    Keyword.create!(word: 'baz')
    expect($redis.get("group_metrics")).to be_nil
    expect($redis.get("user_metrics:#{user.id}")).to be_nil
  end

  it 'reprocesses all comments for approval on keyword change' do
    # Initially not approved
    expect(comment.reload.approved).to be_nil
    # Add a keyword that matches comment body
    Keyword.create!(word: 'foo')
    Keyword.create!(word: 'bar')
    expect(comment.reload.approved).to eq(true)
    expect(comment.reload.state).to eq('approved')
  end
end
