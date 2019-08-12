# frozen_string_literal: true

module DiscourseAnonymousModerators
  class Manager

    def self.get_parent(user)
      return unless SiteSetting.anonymous_moderators_enabled
      return unless user

      if anonymous_link = Link.find_by(user: user, deactivated_at: nil)
        fetch_parent_user(anonymous_link)
      else
        raise Discourse::NotFound
      end
    end

    def self.get_child(user)
      return unless SiteSetting.anonymous_moderators_enabled
      return unless user

      anonymous_link = Link.find_by(parent_user: user, deactivated_at: nil)
      if anonymous_link.nil?
        anonymous_link = create_child(user)
      end

      fetch_anonymous_user(anonymous_link)
    end

    private

    def self.fetch_anonymous_user(anonymous_link)
      raise Discourse::InvalidAccess unless acceptable_link?(anonymous_link)
      anonymous_link.user.update!(Manager.enforced_child_params(parent: anonymous_link.parent_user, child: anonymous_link.user))
      anonymous_link.user
    end

    def self.fetch_parent_user(anonymous_link)
      raise Discourse::InvalidAccess unless acceptable_link?(anonymous_link)
      anonymous_link.parent_user
    end

    def self.acceptable_parent?(user)
      return false if !user.staff?
      return false if Link.exists?(user: user) # Is already a child
      true
    end

    def self.acceptable_child?(user)
      return false if user.admin
      return false if Link.exists?(parent_user: user) # Is a parent
      true
    end

    def self.acceptable_link?(anonymous_link)
      return false unless acceptable_child?(anonymous_link.user)
      return false unless acceptable_parent?(anonymous_link.parent_user)
      true
    end

    def self.create_child(user)
      raise Discourse::InvalidAccess unless acceptable_parent?(user)
      User.transaction do
        create_params = {
          password: SecureRandom.hex,
          approved_at: 1.day.ago,
          created_at: 1.day.ago # bypass new user restrictions
        }

        create_params.merge!(enforced_child_params(parent: user))

        child = User.create!(create_params)

        child.user_option.update_columns(
          email_digests: false
        )

        Link.create!(user: child, parent_user: user, last_used_at: Time.zone.now)
      end
    end

    def self.enforced_child_params(parent: , child: nil)
      username = child&.username || UserNameSuggester.suggest(SiteSetting.anonymous_moderators_username_prefix)
      email = parent.email.sub('@', "+#{username}@") # Use plus addressing

      params = {
        email: email,
        skip_email_validation: true,
        name: username, # prevents error when names are required
        active: true,
        trust_level: 1,
        manual_locked_trust_level: 1,
        moderator: true,
        approved: true
      }
      params.merge!(username: username) unless child

      params
    end

  end
end
