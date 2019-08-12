# frozen_string_literal: true

module DiscourseAnonymousModerators
  class Link < ActiveRecord::Base
    belongs_to :user
    belongs_to :parent_user, class_name: :User
  end
end

# == Schema Information
#
# Table name: anonymous_user_links
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)        not null
#  parent_user_id :bigint(8)        not null
#  last_used_at   :datetime         not null
#  created_at     :datetime         not null
#  deactivated_at :datetime
#
# Indexes
#
#  index_anonymous_user_links_on_parent_user_id              (parent_user_id)
#  index_anonymous_user_links_on_user_id                     (user_id)
#  index_anonymous_user_links_on_user_id_and_parent_user_id  (user_id,parent_user_id) UNIQUE WHERE (deactivated_at IS NULL)
#
