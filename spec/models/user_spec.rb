require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create!(username: 'TestUser', external_id: 1) }
  let!(:post) { Post.create!(user: user, external_id: 1, title: 'Test', body: 'Test') }

  before do
    $redis.set("user_metrics:#{user.id}", {foo: 1}.to_json)
    $redis.set("group_metrics", {bar: 2}.to_json)
  end

  it 'invalidates metrics cache on user update' do
    expect($redis.get("user_metrics:#{user.id}")).not_to be_nil
    expect($redis.get("group_metrics")).not_to be_nil
    user.update!(username: 'Changed')
    expect($redis.get("user_metrics:#{user.id}")).to be_nil
    expect($redis.get("group_metrics")).to be_nil
  end

  it 'has many posts' do
    expect(user.posts).to include(post)
  end
end
