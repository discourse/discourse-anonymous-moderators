# frozen_string_literal: true

module DiscourseAnonymousModerators
  class Link < ActiveRecord::Base
    belongs_to :user
    belongs_to :parent_user, class_name: :User
  end
end

# == Schema Information
#
# Table name: discourse_anonymous_moderators_links
#
#  id             :bigint           not null, primary key
#  user_id        :bigint           not null
#  parent_user_id :bigint           not null
#  last_used_at   :datetime         not null
#  created_at     :datetime         not null
#  deactivated_at :datetime
#
# Indexes
#
#  index_discourse_anonymous_moderators_links_on_parent_user_id  (parent_user_id) UNIQUE WHERE (deactivated_at IS NULL)
#  index_discourse_anonymous_moderators_links_on_user_id         (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (parent_user_id => users.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
