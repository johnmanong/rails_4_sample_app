require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "profile page" do
    # create user model object
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should show_profile_page }    
  end

  describe 'signup page' do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    it { should show_signup_page }

    describe "with invalid info" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before do
          click_button submit
        end

        it { should show_signup_page }
        it { should have_this_many_errors(6) }
        it { should have_error_message('There was a problem signing you up') }
      end

    end

    describe "with valid info" do
      before do
        fill_in_valid_sign_up_info
      end
      it "should create one user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should show_profile_page }
        it { should reflect_signed_in }
        it { should have_success_message('Welcome') }
      end

    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }
    describe "page" do
      it { should show_edit_page }
      it { should have_title 'Edit user' }
      it { should have_link 'change', href: 'http://gravatar.com/emails'}
    end

    describe "invalid info" do
      before { click_button 'Save changes' }

      it { should have_this_many_errors(2) }
      it { should show_edit_page }

      it { should have_title 'Edit user' }
      it { should have_content('error')}      
    end

  end
end
