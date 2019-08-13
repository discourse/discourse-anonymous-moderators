# frozen_string_literal: true

class ChangeAnonymousUserLinksToDiscourseAnonymousModeratorsLinks < ActiveRecord::Migration[5.2]
  def change
    Migration::SafeMigrate.disable!
    rename_table :anonymous_user_links, :discourse_anonymous_moderators_links
  ensure
    Migration::SafeMigrate.enable!
  end
end
