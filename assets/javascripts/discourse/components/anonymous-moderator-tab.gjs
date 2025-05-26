import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

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

  <template>
    <div class="anonymous-moderator-switcher">
      <div class="anonymous-moderator-switcher__header">
        <span class="anonymous-moderator-switcher__user">
          {{i18n
            "anonymous_moderators.current_account"
            username=this.currentUser.username
          }}
        </span>

        <span class="anonymous-moderator-switcher__status">
          {{#if this.currentUser.can_become_anonymous_moderator}}
            {{i18n "anonymous_moderators.signed_in_main"}}
          {{else}}
            {{i18n "anonymous_moderators.signed_in_anon"}}
          {{/if}}
        </span>
      </div>

      {{#if this.currentUser.can_become_anonymous_moderator}}
        <DButton
          @action={{this.becomeAnonModerator}}
          @label="anonymous_moderators.switch_to_anon"
          @icon="user-secret"
          @isLoading={{this.loading}}
        />
      {{else if this.currentUser.is_anonymous_moderator}}
        <DButton
          @action={{this.becomeMasterUser}}
          @label="anonymous_moderators.switch_to_master"
          @icon="user-secret"
          @isLoading={{this.loading}}
        />
      {{/if}}
    </div>
  </template>
}
