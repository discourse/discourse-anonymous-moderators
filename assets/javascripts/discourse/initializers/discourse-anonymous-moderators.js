import { service } from "@ember/service";
import { withPluginApi } from "discourse/lib/plugin-api";
import AnonymousModeratorTab from "../components/anonymous-moderator-tab";
import AnonymousParentUsername from "../components/anonymous-parent-username";

function initializeAnonymousUser(api) {
  api.registerUserMenuTab((UserMenuTab) => {
    return class extends UserMenuTab {
      @service currentUser;

      id = "anonymous_moderator";
      icon = "user-secret";
      panelComponent = AnonymousModeratorTab;

      get shouldDisplay() {
        return (
          this.currentUser?.can_become_anonymous_moderator ||
          this.currentUser?.is_anonymous_moderator
        );
      }
    };
  });

  customizePost(api);
}

function customizePost(api) {
  api.renderAfterWrapperOutlet(
    "post-meta-data-poster-name",
    AnonymousParentUsername
  );
}

export default {
  name: "discourse-anonymous-moderators",

  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");

    if (siteSettings.anonymous_moderators_enabled) {
      withPluginApi(initializeAnonymousUser);
    }
  },
};
