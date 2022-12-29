# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseAnonymousModerators::SwitchController do
  before { SiteSetting.anonymous_moderators_enabled = true }

  let(:user) { Fabricate(:user, moderator: true) }

  it "doesn't allow anon" do
    post "/anonymous-moderators/become-anon.json"
    expect(response.status).to eq(403)
    post "/anonymous-moderators/become-master.json"
    expect(response.status).to eq(403)
  end

  context "when logged in" do
    before { sign_in(user) }

    it "doesn't work when plugin is disabled" do
      post "/anonymous-moderators/become-anon.json"
      expect(response.status).to eq(200)
      SiteSetting.anonymous_moderators_enabled = false
      post "/anonymous-moderators/become-anon.json"
      expect(response.status).to eq(404)
    end

    it "applies checks correctly" do
      sign_in Fabricate(:user)
      post "/anonymous-moderators/become-anon.json"
      expect(response.status).to eq(403)
    end

    it "switches user correctly" do
      expect(session[:current_user_id]).to eq(user.id)
      post "/anonymous-moderators/become-anon.json"
      anon_user_id = session[:current_user_id]
      expect(anon_user_id).not_to eq(user.id)
      post "/anonymous-moderators/become-master.json"
      expect(session[:current_user_id]).to eq(user.id)
      post "/anonymous-moderators/become-anon.json"
      expect(session[:current_user_id]).to eq(anon_user_id)
    end
  end
end
