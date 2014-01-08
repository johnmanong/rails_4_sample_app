require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }

  describe "signin" do
    before { visit signin_path }

    let(:signin_btn)  { "Sign in" }

    describe "with invalid info" do
      before do
        click_button signin_btn
      end

      it { should have_title("Sign in") }
      it { should have_error_message('Invalid') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }  
      end
    end

    describe "with valid info" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        valid_signin(user)
      end

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by sign out" do
        before { click_link "Sign out" }

        it { should have_link('Sign in', href: signin_path) }
        it { should_not have_link('Sign out', href: signout_path) }
      end
    end

  end
end
