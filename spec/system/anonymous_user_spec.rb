# frozen_string_literal: true

RSpec.describe "Anonymous Moderator Parent Username", type: :system do
  before { SiteSetting.anonymous_moderators_enabled = true }

  fab!(:user)
  let!(:user1) { Fabricate(:user) }
  let!(:user2) { Fabricate(:user) }
  let!(:link) do
    DiscourseAnonymousModerators::Link.create!(
      user: user1,
      parent_user: user2,
      last_used_at: Time.zone.now,
    )
  end
  fab!(:moderator)

  fab!(:topic)
  let!(:post) { Fabricate(:post, topic: topic, user: user) }
  let!(:post2) { Fabricate(:post, topic: topic, user: user1) }
  let!(:post3) { Fabricate(:post, topic: topic, user: user2) }

  context "for staff" do
    before do
      SiteSetting.anonymous_moderators_enabled = true
      sign_in(moderator)
    end

    it "includes the parent username indicator in the poster name" do
      visit "/t/#{topic.slug}/#{topic.id}"

      expect(page).to have_css("span.poster-parent-username > a.anon-identity")

      parent_username_indicator = page.find("span.poster-parent-username > a.anon-identity")

      expect(parent_username_indicator["data-user-card"]).to eq(user2.username)
      expect(parent_username_indicator.text).to have_text(user2.username)
    end
  end
end
