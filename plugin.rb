# frozen_string_literal: true

# name: discourse-anonymous-moderators
# about: Allow moderators to have an alternative account for performing actions
# version: 1.0
# authors: David Taylor
# url: https://github.com/discourse/discourse-anonymous-moderators

enabled_site_setting :anonymous_moderators_enabled

require_relative "lib/anonymous_moderators/engine"
require_relative "lib/anonymous_moderators/manager"

register_asset 'stylesheets/anonymous_moderators.scss'

after_initialize do

  add_to_class(:user, :is_anonymous_moderator) do
    return DiscourseAnonymousModerators::Link.exists?(user: self)
  end

  add_to_class(:user, :can_become_anonymous_moderator) do
    return DiscourseAnonymousModerators::Manager.acceptable_parent?(self)
  end

  add_to_serializer(:current_user, :is_anonymous_moderator) do
    object.is_anonymous_moderator
  end

  add_to_serializer(:current_user, :can_become_anonymous_moderator) do
    object.can_become_anonymous_moderator
  end

  add_model_callback("DiscourseAnonymousModerators::Link", :after_commit, on: [ :create, :update ]) do
    UserCustomField.find_or_initialize_by(user: user, name: :parent_user_username).update_attributes!(value: parent_user.username)
  end

  whitelist_staff_user_custom_field :parent_user_username

  module ModifyUserEmail
    def execute(args)
      return super(args) unless SiteSetting.anonymous_moderators_enabled

      if parent = DiscourseAnonymousModerators::Link.find_by(user_id: args[:user_id])&.parent_user
        args[:to_address] = parent.email
      end
      super(args)
    end
  end

  ::Jobs::UserEmail.class_eval do
    prepend ModifyUserEmail
  end
end
