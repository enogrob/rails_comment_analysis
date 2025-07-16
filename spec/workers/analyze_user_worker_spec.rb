require 'rails_helper'

RSpec.describe AnalyzeUserWorker, type: :worker do
  let(:username) { 'TestUser' }
  let(:user) { instance_double(User, id: 1, posts: []) }

  before do
    allow(ImportUserDataService).to receive(:new).with(username).and_return(double(call: true))
    allow(User).to receive(:find_by).with(username: username).and_return(user)
    allow(CommentMetricsService).to receive(:calculate_for_user).with(user).and_return({})
    allow(CommentMetricsService).to receive(:calculate_for_group).and_return({})
  end

  it 'calls ImportUserDataService and calculates metrics if user exists' do
    expect(ImportUserDataService).to receive(:new).with(username).and_return(double(call: true))
    expect(User).to receive(:find_by).with(username: username).and_return(user)
    expect(CommentMetricsService).to receive(:calculate_for_user).with(user)
    expect(CommentMetricsService).to receive(:calculate_for_group)
    described_class.new.perform(username)
  end

  it 'does not calculate metrics if user does not exist' do
    allow(User).to receive(:find_by).with(username: username).and_return(nil)
    expect(CommentMetricsService).not_to receive(:calculate_for_user)
    expect(CommentMetricsService).not_to receive(:calculate_for_group)
    described_class.new.perform(username)
  end
end
