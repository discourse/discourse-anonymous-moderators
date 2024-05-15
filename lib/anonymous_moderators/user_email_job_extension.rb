# frozen_string_literal: true

module DiscourseAnonymousModerators
  module UserEmailJobExtension
    extend ActiveSupport::Concern

    def execute(args)
      return super(args) unless SiteSetting.anonymous_moderators_enabled

      if parent = DiscourseAnonymousModerators::Link.find_by(user_id: args[:user_id])&.parent_user
        args[:to_address] = parent.email
      end
      super(args)
    end
  end
end
