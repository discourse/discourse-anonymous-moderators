import discourseComputed from "discourse-common/utils/decorators";
import { userPath } from "discourse/lib/url";

export default Ember.Component.extend({
  @discourseComputed("user.custom_fields.parent_user_username")
  username(username) {
    return username;
  },

  @discourseComputed("username")
  link(username) {
    return userPath(username);
  },

  @discourseComputed("username")
  shouldDisplay(username) {
    return this.get("currentUser.staff") && username;
  },

  @discourseComputed("username")
  dataUserCard(username) {
    if (this.get("noCard")) {
      return false;
    }
    return username;
  }
});
