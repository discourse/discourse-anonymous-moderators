import { default as computed } from "ember-addons/ember-computed-decorators";
import { userPath } from "discourse/lib/url";

export default Ember.Component.extend({
  @computed("user.custom_fields.parent_user_username")
  username(username) {
    return username;
  },

  @computed("username")
  link(username) {
    return userPath(username);
  },

  @computed("username")
  shouldDisplay(username) {
    return this.get("currentUser.staff") && username;
  },

  @computed("username")
  dataUserCard(username) {
    if (this.get("noCard")) {
      return false;
    }
    return username;
  }
});
