import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import AnonymousIdentity from "../../components/anonymous-identity";

@tagName("div")
@classNames("user-card-post-names-outlet", "anonymous-user-identity")
export default class AnonymousUserIdentity extends Component {
  <template>
    <AnonymousIdentity @user={{this.user}} @noCard={{true}} />
  </template>
}
