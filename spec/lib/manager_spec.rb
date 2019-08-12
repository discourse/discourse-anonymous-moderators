# frozen_string_literal: true

require 'rails_helper'

describe DiscourseAnonymousModerators::Manager do
  let(:parent1) { Fabricate(:user) }
  let(:anon1) { Fabricate(:user) }

  let(:admin_parent) { Fabricate(:user, admin: true) }

  let(:moderator_parent) { Fabricate(:user, moderator: true) }
  let(:moderator_anon) { Fabricate(:user, moderator: true) }
  let(:moderator_anon2) { Fabricate(:user, moderator: true) }

  let(:link_mod_to_mod) { DiscourseAnonymousModerators::Link.create!(user: moderator_anon, parent_user: moderator_parent, last_used_at: Time.zone.now) }
  let(:deactivated_link) { DiscourseAnonymousModerators::Link.create!(user: moderator_anon2, parent_user: moderator_parent, last_used_at: Time.zone.now, deactivated_at: Time.zone.now) }

  before do
    SiteSetting.anonymous_moderators_enabled = true
  end

  describe "switching to existing anonymous account" do

    it "returns nil when disabled" do
      link_mod_to_mod
      expect(DiscourseAnonymousModerators::Manager.get_child(moderator_parent)).to eq(moderator_anon)
      SiteSetting.anonymous_moderators_enabled = false
      expect(DiscourseAnonymousModerators::Manager.get_child(moderator_parent)).to eq(nil)
    end

    it "finds an associated account correctly" do
      link_mod_to_mod
      expect(DiscourseAnonymousModerators::Manager.get_child(moderator_parent)).to eq(moderator_anon)
    end

    it "ignores deactivated links" do
      link_mod_to_mod
      deactivated_link
      expect(DiscourseAnonymousModerators::Link.where(parent_user: moderator_parent).count).to eq(2)
      expect(DiscourseAnonymousModerators::Manager.get_child(moderator_parent)).to eq(moderator_anon)
    end

    it "checks the parent correctly" do
      link_mod_to_mod
      moderator_parent.update!(moderator: false)
      expect { DiscourseAnonymousModerators::Manager.get_child(moderator_parent) }.to raise_error(Discourse::InvalidAccess)
    end

    it "checks the child correctly" do
      link_mod_to_mod
      moderator_anon.update!(admin: true)
      expect { DiscourseAnonymousModerators::Manager.get_child(moderator_parent) }.to raise_error(Discourse::InvalidAccess)
    end

  end

  describe "acceptable_parent?" do
    it "does not allow regular users" do
      expect(DiscourseAnonymousModerators::Manager.acceptable_parent?(moderator_parent)).to eq(true)
      expect(DiscourseAnonymousModerators::Manager.acceptable_parent?(parent1)).to eq(false)
    end

    it "does not allow children to be parents" do
      link_mod_to_mod
      expect(DiscourseAnonymousModerators::Manager.acceptable_parent?(moderator_anon)).to eq(false)
    end
  end

  describe "acceptable_child?" do
    it "denies admins" do
      expect(DiscourseAnonymousModerators::Manager.acceptable_child?(admin_parent)).to eq(false)
    end

    it "does not allow parents to be children" do
      link_mod_to_mod
      expect(DiscourseAnonymousModerators::Manager.acceptable_child?(moderator_parent)).to eq(false)
    end

  end

  describe "create_child" do
    it "works correctly" do
      newlink = DiscourseAnonymousModerators::Manager.create_child(moderator_parent)
      expect(DiscourseAnonymousModerators::Manager.get_child(moderator_parent)).to eq(newlink.user)

      expect(newlink.user.email).to eq(moderator_parent.email.sub("@", "+#{newlink.user.username}@"))
      expect(newlink.user.moderator).to eq(true)
    end
  end

  describe "enforced_child_parameters" do
    it "works with child" do
      params = DiscourseAnonymousModerators::Manager.enforced_child_params(parent: moderator_parent, child: moderator_anon)
      expect(params[:username]).to eq(nil)
      expect(params[:active]).to eq(true)
    end

    it "works without child" do
      params = DiscourseAnonymousModerators::Manager.enforced_child_params(parent: moderator_parent)
      expect(params[:username].starts_with?(SiteSetting.anonymous_moderators_username_prefix)).to eq(true)
    end
  end

end
