import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default class AnonymousModeratorTab extends Component {
  @service currentUser;

  @tracked loading = false;

  @action
  async becomeAnonModerator() {
    this.loading = true;

    await ajax("/anonymous-moderators/become-anon", { method: "POST" });
    window.location.reload();
  }

  @action
  async becomeMasterUser() {
    this.loading = true;

    await ajax("/anonymous-moderators/become-master", { method: "POST" });
    window.location.reload();
  }
}
