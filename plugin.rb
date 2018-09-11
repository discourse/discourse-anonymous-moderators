# name: discourse-anonymous-user
# about: Allow users to have an alternative account for posting anonymously
# version: 0.1
# authors: David Taylor
# url: https://github.com/discourse/discourse-anonymous-user

enabled_site_setting :anonymous_user_enabled

require_relative "lib/anonymous_user/engine"
require_relative "lib/anonymous_user/manager"

after_initialize do

  add_to_class(:user, :is_anonymous_user) do
    return AnonymousUser::Link.exists?(user: self)
  end

  add_to_class(:user, :can_become_anonymous) do
    return AnonymousUser::Manager.acceptable_parent?(self)
  end

  add_to_serializer(:current_user, :is_anonymous_user) do
    object.is_anonymous_user
  end

  add_to_serializer(:current_user, :can_become_anonymous) do
    object.can_become_anonymous
  end

  add_model_callback("AnonymousUser::Link", :after_commit, on: [ :create, :update ]) do
    UserCustomField.find_or_initialize_by(user: user, name: :parent_user_username).update_attributes!(value: parent_user.username)
  end

  whitelist_staff_user_custom_field :parent_user_username

  # TODO: skip emails for anon, based on site setting. Will likely require a new hook in core
  # TODO: add timeout setting, to match core functionality
  # TODO: core makes post_can_act? false for anon users. Prevents likes/flags
end
