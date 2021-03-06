require 'spec_helper'

describe User do
  before do
    @user = User.new(name: "The Dude", email: "dude@abides.net", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  # basic
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }                 # has_secture_password
  it { should respond_to(:password_confirmation) }    # has_secture_password
  
  # session
  it { should respond_to(:authenticate) }             # has_secture_password
  it { should respond_to(:remember_token) }

  # roles
  it { should respond_to(:admin) }

  # micropost association
  it { should respond_to(:microposts) }

  # micropost feed
  it { should respond_to(:feed) }

  # follower/followed relationship
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }

  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  it { should respond_to(:following?) }

  it { should be_valid }
  it { should_not be_admin }

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }

    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end

    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end

    describe "associated relationships" do
      it "should destory associated relationships" do
        user_relationships = @user.relationships.to_a
        @user.destroy
        expect(user_relationships).not_to be_empty;
        user_relationships.each do |relationship|
          expect(Relationship.where(id:relationship.id)).to be_empty
        end
      end

      it "should destory associated relationships" do
        user_relationships = other_user.reverse_relationships.to_a
        other_user.destroy
        expect(user_relationships).not_to be_empty
        user_relationships.each do |relationship|
          expect(Relationship.where(id: relationship.id)).to be_empty
        end
      end
    end
  end

  describe 'micropost association' do
    before { @user.save }
    
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the microposts in reverse chronological order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      # makes a local copy
      microposts = @user.microposts.to_a
      # destroy user, destroy posts
      @user.destroy
      # check needed to ensure local copy persists
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        # test if microposts are in db
        expect(Micropost.where(id: micropost.id)).to be_empty

        # where prefered over find(), since where() returns an empty obj
        # and find() throws an exception. 
        # An equivalent implementation with find():
        #
        expect do
           Micropost.find(micropost)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'status' do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times do
          followed_user.microposts.create!(content: "Lorem ipsum")
        end
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |post|
          should include(post)
        end
      end

    end
  end

  describe 'when user is admin' do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }

  end

  describe 'when name is not present' do
    before do
      @user.name = ' '  
    end

    it { should_not be_valid }    
  end

  describe 'when name is too long' do
    before {
      @user.name = 'a' * 51
    }
    
    it { should_not be_valid }
  end

  describe 'when email is not present' do
    before do
      @user.email = ' '  
    end

    it { should_not be_valid }
  end

  describe 'when email is not valid format' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email is valid format" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { should_not be_valid }
  end

  describe "when email address is mixed case" do
    let(:mixed_case_email) { "FoO@eXaMpLe.com" }

    it "should downcase email address before saving" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.email).to eq mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "return value of the authenticate method" do
    before { @user.save }

    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "remember_token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
    # same as above
    # it { expect(@user.remember_token).not_to be_blank }
  end

end
