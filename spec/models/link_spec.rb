# frozen_string_literal: true

require 'rails_helper'

describe DiscourseAnonymousUser::Link do
  let(:user1) { Fabricate(:user) }
  let(:user2) { Fabricate(:user) }
  let(:user3) { Fabricate(:user) }

  it "doesn't allow children to have multiple parents" do
    expect { described_class.create!(user: user1, parent_user: user2, last_used_at: Time.zone.now) }.not_to raise_error
    expect { described_class.create!(user: user1, parent_user: user2, last_used_at: Time.zone.now) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "doesn't allow parents to have multiple active children" do
    expect { described_class.create!(user: user1, parent_user: user2, last_used_at: Time.zone.now) }.not_to raise_error
    expect { described_class.create!(user: user3, parent_user: user2, last_used_at: Time.zone.now) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "allows multiple children once deactivated" do
    expect { described_class.create!(user: user1, parent_user: user2, last_used_at: Time.zone.now, deactivated_at: Time.zone.now) }.not_to raise_error
    expect { described_class.create!(user: user3, parent_user: user2, last_used_at: Time.zone.now) }.not_to raise_error
  end

end
