# frozen_string_literal: true

module ::DiscourseAnonymousModerators
  class SwitchController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    before_action :ensure_logged_in

    def become_child
      user = Manager.get_child(current_user)
      if user
        log_on_user(user)
        render json: success_json
      else
        failed_json
      end
    end

    def become_parent
      user = Manager.get_parent(current_user)
      if user
        log_on_user(user)
        render json: success_json
      else
        failed_json
      end
    end
  end
end
