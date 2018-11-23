# discourse-anonymous-user

Allows users to have a second account for participating in the forum anonymously. Optionally Staff can use this plugin to create anonymous moderator accounts.

This replicates the anonymous posting feature in core Discourse, and adds more functionality.

Configuration options available are:

- anonymous_user_enabled: Allow users to access a second 'anonymous' user account?
- anonymous_user_allowed_users: Users with access to anonymous feature. 'users_only' is the most secure!
- anonymous_user_required_trust_level: Required trust level to access the anonymous feature.
- anonymous_user_maintain_moderator: Staff anonymous accounts have moderator privaledges. It is more secure to leave this disabled!
- anonymous_user_username_prefix: Beginning of the username for anonymous accounts.
- anonymous_user_show_identity_staff: Allow staff to see the identity of the anonymous user in the user interface.
