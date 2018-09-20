require 'rails_helper'
require_dependency 'jobs/base'

describe Jobs::UserEmail do
  let(:user) { Fabricate(:user, last_seen_at: 11.minutes.ago) }
  let(:parent_user) { Fabricate(:user, last_seen_at: 11.minutes.ago) }
  let!(:link) { AnonymousUser::Link.create!(user: user, parent_user: parent_user, last_used_at: Time.zone.now) }
  let(:mailer) { Mail::Message.new(to: user.email) }

  before do
    SiteSetting.anonymous_user_enabled = true
  end

  it 'overwrites the to_address for anonymous users' do
    UserNotifications.expects(:confirm_new_email).returns(mailer)
    Email::Sender.any_instance.expects(:send)
    Jobs::UserEmail.new.execute(type: :confirm_new_email, user_id: user.id)
    expect(mailer.to).to eq([parent_user.email])
  end
end
