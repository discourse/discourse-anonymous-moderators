import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

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
