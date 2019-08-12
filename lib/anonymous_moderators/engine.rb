# frozen_string_literal: true

module ::DiscourseAnonymousModerators
  PLUGIN_NAME = "discourse-anonymous-moderators"

  class Engine < ::Rails::Engine
    engine_name DiscourseAnonymousModerators::PLUGIN_NAME
    isolate_namespace DiscourseAnonymousModerators
  end
end
