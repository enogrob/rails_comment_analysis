require 'rails_helper'

describe CommentMetricsService do
  let(:user) { User.create!(username: 'TestUser', external_id: 1) }
  let(:post1) { Post.create!(user: user, external_id: 1, title: 'Post1', body: 'Body1') }
  let(:post2) { Post.create!(user: user, external_id: 2, title: 'Post2', body: 'Body2') }

  before do
    Comment.create!(post: post1, external_id: 1, body: 'short', state: 'approved', approved: true)
    Comment.create!(post: post1, external_id: 2, body: 'a bit longer', state: 'approved', approved: true)
    Comment.create!(post: post2, external_id: 3, body: 'the longest comment body here', state: 'rejected', approved: false)
    $redis.flushdb if defined?($redis)
  end

  describe '.calculate_for_user' do
    it 'returns metrics for a user' do
      metrics = described_class.calculate_for_user(user)
      expect(metrics).to include(:mean, :median, :stddev, :count)
      expect(metrics[:count]).to eq(3)
    end

    it 'caches the result' do
      described_class.calculate_for_user(user)
      expect($redis.get("user_metrics:#{user.id}")).not_to be_nil
    end
  end

  describe '.calculate_for_group' do
    it 'returns metrics for all comments' do
      metrics = described_class.calculate_for_group
      expect(metrics).to include(:mean, :median, :stddev, :count)
      expect(metrics[:count]).to eq(3)
    end

    it 'caches the result' do
      described_class.calculate_for_group
      expect($redis.get('group_metrics')).not_to be_nil
    end
  end

  describe '.calculate_metrics' do
    it 'returns zeros for empty comments' do
      expect(described_class.calculate_metrics([])).to eq({ mean: 0, median: 0, stddev: 0 })
    end

    it 'calculates correct stats' do
      comments = Comment.all
      metrics = described_class.calculate_metrics(comments)
      expect(metrics[:count]).to eq(3)
      expect(metrics[:mean]).to be > 0
      expect(metrics[:median]).to be > 0
      expect(metrics[:stddev]).to be >= 0
    end
  end
end
