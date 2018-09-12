describe UserSerializer do

  before do
    SiteSetting.anonymous_user_enabled = true
  end

  let(:user1) { Fabricate(:user) }
  let(:user2) { Fabricate(:user) }
  let!(:link) { AnonymousUser::Link.create!(user: user1, parent_user: user2, last_used_at: Time.zone.now) }
  let(:moderator) { Fabricate(:moderator) }

  context "for regular users" do
    let(:serializer) { UserSerializer.new(user1, scope: Guardian.new(user2), root: false) }
    let(:json) { serializer.as_json }

    it "doesn't include parent username" do
      expect(json[:custom_fields]).not_to have_key("parent_user_username")
    end

    it "doesn't include is_anonymous_user" do
      expect(json[:custom_fields]).not_to have_key(:is_anonymous_user)
    end
  end

  context "for self" do
    let(:serializer) { CurrentUserSerializer.new(user1, scope: Guardian.new(user1), root: false) }
    let(:json) { serializer.as_json }

    it "includes is_anonymous_user" do
      expect(json).to have_key(:is_anonymous_user)
      expect(json[:is_anonymous_user]).to eq(true)
    end
  end

  context "for staff" do
    let(:serializer) { UserSerializer.new(user1, scope: Guardian.new(moderator), root: false) }
    let(:json) { serializer.as_json }

    it "includes parent username" do
      expect(json[:custom_fields]).to have_key("parent_user_username")
      expect(json[:custom_fields]["parent_user_username"]).to eq(user2.username)
    end
  end

end
