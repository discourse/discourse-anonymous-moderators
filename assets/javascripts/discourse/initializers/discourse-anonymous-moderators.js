import { withPluginApi } from "discourse/lib/plugin-api";
import { iconNode } from "discourse-common/lib/icon-library";
import { userPath } from "discourse/lib/url";
import AnonymousModeratorTab from "../components/anonymous-moderator-tab";
import { inject as service } from "@ember/service";

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

  api.decorateWidget(`poster-name:after`, (dec) => {
    const username = dec.attrs.userCustomFields?.parent_user_username;
    if (!username) {
      return null;
    }

    return dec.h(
      "span.poster-parent-username",
      dec.h(
        "a.anon-identity",
        {
          attributes: {
            "data-user-card": username,
            href: userPath(),
          },
        },
        [iconNode("user-secret"), ` ${username}`]
      )
    );
  });
}

export default {
  name: "discourse-anonymous-moderators",

  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");
    if (siteSettings.anonymous_moderators_enabled) {
      withPluginApi("0.8", initializeAnonymousUser);
    }
  },
};