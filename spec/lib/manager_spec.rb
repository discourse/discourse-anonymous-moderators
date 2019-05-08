require 'rails_helper'

describe AnonymousUser::Manager do
  let(:parent1) { Fabricate(:user) }
  let(:anon1) { Fabricate(:user) }
  let(:anon2) { Fabricate(:user) }
  let(:tl2_anon) { Fabricate(:user, trust_level: TrustLevel[2]) }

  let(:admin_parent) { Fabricate(:user, admin: true) }

  let(:moderator_parent) { Fabricate(:user, moderator: true) }
  let(:moderator_anon) { Fabricate(:user, moderator: true) }

  let(:link) { AnonymousUser::Link.create!(user: anon1, parent_user: parent1, last_used_at: Time.zone.now) }
  let(:link_mod_to_mod) { AnonymousUser::Link.create!(user: moderator_anon, parent_user: moderator_parent, last_used_at: Time.zone.now) }
  let(:link_mod_to_regular) { AnonymousUser::Link.create!(user: anon1, parent_user: moderator_parent, last_used_at: Time.zone.now) }
  let(:link_regular_to_mod) { AnonymousUser::Link.create!(user: moderator_anon, parent_user: parent1, last_used_at: Time.zone.now) }
  let(:deactivated_link) { AnonymousUser::Link.create!(user: anon2, parent_user: parent1, last_used_at: Time.zone.now, deactivated_at: Time.zone.now) }

  before do
    SiteSetting.anonymous_user_enabled = true
  end

  describe "switching to existing anonymous account" do

    it "returns nil when disabled" do
      link
      expect(AnonymousUser::Manager.get_child(parent1)).to eq(anon1)
      SiteSetting.anonymous_user_enabled = false
      expect(AnonymousUser::Manager.get_child(parent1)).to eq(nil)
    end

    it "finds an associated account correctly" do
      link
      expect(AnonymousUser::Manager.get_child(parent1)).to eq(anon1)
    end

    it "ignores deactivated links" do
      link
      deactivated_link
      expect(AnonymousUser::Link.where(parent_user: parent1).count).to eq(2)
      expect(AnonymousUser::Manager.get_child(parent1)).to eq(anon1)
    end

    it "checks the parent correctly" do
      link
      anon1.update!(admin: true)
      expect { AnonymousUser::Manager.get_child(parent1) }.to raise_error(Discourse::InvalidAccess)
    end

    it "checks the child correctly" do
      link
      link_mod_to_mod
      expect { AnonymousUser::Manager.get_child(moderator_parent) }.to raise_error(Discourse::InvalidAccess)
    end

  end

  describe "acceptable_parent?" do
    it "allows only regular users by default" do
      expect(AnonymousUser::Manager.acceptable_parent?(moderator_parent)).to eq(false)
      expect(AnonymousUser::Manager.acceptable_parent?(parent1)).to eq(true)
    end

    it "allows users and staff when configured" do
      SiteSetting.anonymous_user_allowed_users = :users_and_staff
      expect(AnonymousUser::Manager.acceptable_parent?(moderator_parent)).to eq(true)
      expect(AnonymousUser::Manager.acceptable_parent?(parent1)).to eq(true)
    end

    it "allows only staff when configured" do
      SiteSetting.anonymous_user_allowed_users = :staff_only
      expect(AnonymousUser::Manager.acceptable_parent?(moderator_parent)).to eq(true)
      expect(AnonymousUser::Manager.acceptable_parent?(parent1)).to eq(false)
    end

    it "restricts by trust level" do
      expect(AnonymousUser::Manager.acceptable_parent?(parent1)).to eq(true)
      SiteSetting.anonymous_user_required_trust_level = 2
      expect(AnonymousUser::Manager.acceptable_parent?(parent1)).to eq(false)
    end

    it "does not allow children to be parents" do
      link
      expect(AnonymousUser::Manager.acceptable_parent?(anon1)).to eq(false)
    end
  end

  describe "acceptable_child?" do
    it "denies admins" do
      expect(AnonymousUser::Manager.acceptable_child?(admin_parent)).to eq(false)
    end

    it "only allows moderators if configured" do
      expect(AnonymousUser::Manager.acceptable_child?(moderator_anon)).to eq(false)
      SiteSetting.anonymous_user_maintain_moderator = true
      expect(AnonymousUser::Manager.acceptable_child?(moderator_anon)).to eq(true)
    end

    it "only allows tl1 users" do
      expect(AnonymousUser::Manager.acceptable_child?(anon1)).to eq(true)
      expect(AnonymousUser::Manager.acceptable_child?(tl2_anon)).to eq(false)
      SiteSetting.anonymous_user_allowed_users = :staff_only
      expect(AnonymousUser::Manager.acceptable_child?(tl2_anon)).to eq(true)
    end

    it "does not allow parents to be children" do
      link
      expect(AnonymousUser::Manager.acceptable_child?(parent1)).to eq(false)
    end

  end

  describe "create_child" do
    it "works correctly" do
      newlink = AnonymousUser::Manager.create_child(parent1)
      expect(AnonymousUser::Manager.get_child(parent1)).to eq(newlink.user)

      expect(newlink.user.email).to eq(parent1.email.sub("@", "+#{newlink.user.username}@"))
      expect(newlink.user.moderator).to eq(false)
    end
  end

  describe "enforced_child_parameters" do
    it "works with child" do
      params = AnonymousUser::Manager.enforced_child_params(parent: parent1, child: anon1)
      expect(params[:username]).to eq(nil)
      expect(params[:active]).to eq(true)
    end

    it "works without child" do
      params = AnonymousUser::Manager.enforced_child_params(parent: parent1)
      expect(params[:username].starts_with?(SiteSetting.anonymous_user_username_prefix)).to eq(true)
    end
  end

end
