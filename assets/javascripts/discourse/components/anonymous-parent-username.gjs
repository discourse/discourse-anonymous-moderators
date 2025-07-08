import Component from "@glimmer/component";
import icon from "discourse/helpers/d-icon";
import { userPath } from "discourse/lib/url";

export default class AnonymousParentUsername extends Component {
  static shouldRender(args) {
    return args.post.user_custom_fields?.parent_user_username;
  }

  get username() {
    return this.args.post.user_custom_fields?.parent_user_username;
  }

  <template>
    <span class="poster-parent-username">
      <a
        class="anon-identity"
        data-user-card={{this.username}}
        href={{userPath this.username}}
      >
        {{icon "user-secret"}}
        {{this.username}}
      </a>
    </span>
  </template>
}
