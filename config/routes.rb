# frozen_string_literal: true

DiscourseAnonymousUser::Engine.routes.draw do
  post '/become-anon' => 'switch#become_child'
  post '/become-master' => 'switch#become_parent'
end

::Discourse::Application.routes.append do
  mount ::DiscourseAnonymousUser::Engine, at: '/anonymous-user'
end
