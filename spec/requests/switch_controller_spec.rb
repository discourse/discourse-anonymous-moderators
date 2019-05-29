# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiscourseAnonymousUser::SwitchController do

  before do
    SiteSetting.anonymous_user_enabled = true
  end

  let(:user) { Fabricate(:user) }

  it "doesn't allow anon" do
    post "/anonymous-user/become-anon.json"
    expect(response.status).to eq(403)
    post "/anonymous-user/become-master.json"
    expect(response.status).to eq(403)
  end

  context "when logged in" do
    before do
      sign_in(user)
    end

    it "doesn't work when plugin is disabled" do
      post "/anonymous-user/become-anon.json"
      expect(response.status).to eq(200)
      SiteSetting.anonymous_user_enabled = false
      post "/anonymous-user/become-anon.json"
      expect(response.status).to eq(404)
    end

    it "applies checks correctly" do
      SiteSetting.anonymous_user_required_trust_level = 2
      post "/anonymous-user/become-anon.json"
      expect(response.status).to eq(403)
    end

    it "applies checks correctly" do
      SiteSetting.anonymous_user_required_trust_level = 2
      post "/anonymous-user/become-anon.json"
      expect(response.status).to eq(403)
    end

    it "switches user correctly" do
      expect(session[:current_user_id]).to eq(user.id)
      post "/anonymous-user/become-anon.json"
      anon_user_id = session[:current_user_id]
      expect(anon_user_id).not_to eq(user.id)
      post "/anonymous-user/become-master.json"
      expect(session[:current_user_id]).to eq(user.id)
      post "/anonymous-user/become-anon.json"
      expect(session[:current_user_id]).to eq(anon_user_id)
    end

  end

end
