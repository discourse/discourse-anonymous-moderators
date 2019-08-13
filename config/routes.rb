# frozen_string_literal: true

DiscourseAnonymousModerators::Engine.routes.draw do
  post '/become-anon' => 'switch#become_child'
  post '/become-master' => 'switch#become_parent'
end

::Discourse::Application.routes.append do
  mount ::DiscourseAnonymousModerators::Engine, at: '/anonymous-moderators'
end
