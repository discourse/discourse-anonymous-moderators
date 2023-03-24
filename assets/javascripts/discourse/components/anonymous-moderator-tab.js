import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

export default class AnonymousModeratorTab extends Component {
  @service currentUser;
  @tracked loading = false;

  @action
  becomeAnonModerator() {
    this.loading = true;
    ajax("/anonymous-moderators/become-anon", { method: "POST" }).then(() => {
      window.location.reload();
    });
  }

  @action
  becomeMasterUser() {
    this.loading = true;
    ajax("/anonymous-moderators/become-master", { method: "POST" }).then(() => {
      window.location.reload();
    });
  }
}
