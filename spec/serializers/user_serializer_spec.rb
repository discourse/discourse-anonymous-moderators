# frozen_string_literal: true

require "rails_helper"

describe UserSerializer do
  before { SiteSetting.anonymous_moderators_enabled = true }

  let(:user1) { Fabricate(:user) }
  let(:user2) { Fabricate(:user) }
  let!(:link) do
    DiscourseAnonymousModerators::Link.create!(
      user: user1,
      parent_user: user2,
      last_used_at: Time.zone.now,
    )
  end
  let(:moderator) { Fabricate(:moderator) }

  context "for regular users" do
    let(:serializer) { UserSerializer.new(user1, scope: Guardian.new(user2), root: false) }
    let(:json) { serializer.as_json }

    it "doesn't include parent username" do
      expect(json[:custom_fields]).not_to have_key("parent_user_username")
    end

    it "doesn't include is_anonymous_moderator" do
      expect(json[:custom_fields]).not_to have_key(:is_anonymous_moderator)
    end
  end

  context "for self" do
    let(:serializer) { CurrentUserSerializer.new(user1, scope: Guardian.new(user1), root: false) }
    let(:json) { serializer.as_json }

    it "includes is_anonymous_moderator" do
      expect(json).to have_key(:is_anonymous_moderator)
      expect(json[:is_anonymous_moderator]).to eq(true)
    end
  end

  context "for staff" do
    let(:serializer) { UserSerializer.new(user1, scope: Guardian.new(moderator), root: false) }
    let(:json) { serializer.as_json }

    it "includes parent username" do
      expect(json[:custom_fields]).to have_key("parent_user_username")
      expect(json[:custom_fields]["parent_user_username"]).to eq(user2.username)
    end
  end
end
