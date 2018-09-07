import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";

function initializeAnonymousUser(api) {
  api.attachWidgetAction("user-menu", "switchToAnonUser", () => {
    ajax("/anonymous-user/become-anon", { method: "POST" }).then(() => {
      window.location.reload();
    });
  });

  api.attachWidgetAction("user-menu", "switchToMasterUser", () => {
    ajax("/anonymous-user/become-master", { method: "POST" }).then(() => {
      window.location.reload();
    });
  });

  api.addUserMenuGlyph(widget => {
    const user = widget.currentUser;
    if (user.can_become_anonymous) {
      return {
        label: "anonymous_user.switch_to_anon",
        icon: "user-secret",
        action: "switchToAnonUser"
      };
    } else if (user.is_anonymous_user) {
      return {
        label: "anonymous_user.switch_to_master",
        icon: "ban",
        action: "switchToMasterUser"
      };
    } else {
      return false;
    }
  });
}

export default {
  name: "discourse-anonymous-user",

  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (siteSettings.anonymous_user_enabled) {
      withPluginApi("0.8", initializeAnonymousUser);
    }
  }
};
