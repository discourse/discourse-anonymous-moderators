# frozen_string_literal: true

module ::DiscourseAnonymousUser
  PLUGIN_NAME = "discourse-anonymous-user"

  class Engine < ::Rails::Engine
    engine_name DiscourseAnonymousUser::PLUGIN_NAME
    isolate_namespace DiscourseAnonymousUser
  end
end
