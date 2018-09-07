module ::AnonymousUser
  PLUGIN_NAME = "discourse-anonymous-user"

  class Engine < ::Rails::Engine
    engine_name AnonymousUser::PLUGIN_NAME
    isolate_namespace AnonymousUser
  end
end
