module ::AnonymousUser
  class SwitchController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    def become_child
      user = Manager.get_child(current_user)
      if user
        log_on_user(user)
        render json: success_json
      else
        render_json_error
      end
    end

    def become_parent
      user = Manager.get_parent(current_user)
      if user
        log_on_user(user)
        render json: success_json
      else
        render_json_error
      end
    end
  end
end
