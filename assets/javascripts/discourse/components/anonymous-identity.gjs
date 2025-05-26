import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { userPath } from "discourse/lib/url";

export default class AnonymousIdentity extends Component {
  @service currentUser;

  get username() {
    return this.args.user?.custom_fields?.parent_user_username;
  }

  get link() {
    return userPath(this.username);
  }

  get shouldDisplay() {
    return this.currentUser?.staff && this.username;
  }

  get dataUserCard() {
    if (this.args.noCard) {
      return false;
    }

    return this.username;
  }

  <template>
    {{#if this.shouldDisplay}}
      <a
        href={{this.link}}
        data-user-card={{this.dataUserCard}}
        class="anon-identity"
      >
        {{icon "user-secret"}}
        {{this.username}}
      </a>
    {{/if}}
  </template>
}
