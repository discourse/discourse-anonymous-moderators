import { service } from "@ember/service";
import { withSilencedDeprecations } from "discourse/lib/deprecated";
import { iconNode } from "discourse/lib/icon-library";
import { withPluginApi } from "discourse/lib/plugin-api";
import { userPath } from "discourse/lib/url";
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

  withSilencedDeprecations("discourse.post-stream-widget-overrides", () =>
    customizeWidgetPost(api)
  );
}

function customizeWidgetPost(api) {
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
    const siteSettings = container.lookup("service:site-settings");

    if (siteSettings.anonymous_moderators_enabled) {
      withPluginApi(initializeAnonymousUser);
    }
  },
};
