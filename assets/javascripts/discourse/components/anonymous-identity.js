import Component from "@glimmer/component";
import { service } from "@ember/service";
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
}
