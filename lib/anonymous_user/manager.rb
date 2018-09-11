module AnonymousUser
  class Manager

    def self.get_parent(user)
      return unless SiteSetting.anonymous_user_enabled
      return unless user

      if anonymous_link = Link.find_by(user: user, deactivated_at: nil)
        fetch_parent_user(anonymous_link)
      end
    end

    def self.get_child(user)
      return unless SiteSetting.anonymous_user_enabled
      return unless user

      anonymous_link = Link.find_by(parent_user: user, deactivated_at: nil)
      if !anonymous_link && acceptable_parent?(user)
        anonymous_link = create_shadow(user)
      end
      fetch_anonymous_user(anonymous_link)
    end

    private

    def self.fetch_anonymous_user(anonymous_link)
      raise Discourse::InvalidAccess unless acceptable_link?(anonymous_link)
      anonymous_link.user.update!(Manager.enforced_shadow_params(anonymous_link.parent_user, anonymous_link.user))
      anonymous_link.user
    end

    def self.fetch_parent_user(anonymous_link)
      raise Discourse::InvalidAccess unless acceptable_link?(anonymous_link)
      anonymous_link.parent_user
    end

    def self.acceptable_parent?(user)
      return false if SiteSetting.anonymous_user_allowed_users.to_sym == :users_only && user.staff?
      return false if SiteSetting.anonymous_user_allowed_users.to_sym == :staff_only && !user.staff?
      return false unless user.has_trust_level?(SiteSetting.anonymous_user_required_trust_level)
      return false if Link.exists?(user: user) # Is already a child
      true
    end

    def self.acceptable_child?(user)
      return false if user.admin
      return false if user.trust_level > 1
      return false if Link.exists?(parent_user: user) # Is a parent
      if !SiteSetting.anonymous_user_maintain_moderator
        return false if user.moderator
      end
      true
    end

    def self.acceptable_link?(anonymous_link)
      return false unless acceptable_child?(anonymous_link.user)
      return false unless acceptable_parent?(anonymous_link.parent_user)
      true
    end

    def self.create_shadow(user)

      User.transaction do
        create_params = {
          password: SecureRandom.hex,
          approved_at: 1.day.ago,
          created_at: 1.day.ago # bypass new user restrictions
        }

        create_params.merge!(enforced_shadow_params(user, nil))

        shadow = User.create!(create_params)

        shadow.user_option.update_columns(
          email_digests: false
        )

        Link.create!(user: shadow, parent_user: user, last_used_at: Time.zone.now)
      end
    end

    def self.enforced_shadow_params(parent_user, shadow_user)
      username = shadow_user&.username || UserNameSuggester.suggest(SiteSetting.anonymous_user_username_prefix)
      email = parent_user.email.sub('@', "+#{username}@") # Use plus addressing

      if SiteSetting.anonymous_user_maintain_moderator
        moderator = parent_user.moderator || parent_user.admin
      else
        moderator = false
      end

      params = {
        email: email,
        skip_email_validation: true,
        name: username, # prevents error when names are required
        active: true,
        trust_level: 1,
        manual_locked_trust_level: 1,
        moderator: moderator,
        approved: true
      }
      params.merge!(username: username) unless shadow_user

      params
    end

  end
end
