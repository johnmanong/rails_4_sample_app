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

      it { should show_signin_page }
      it { should have_error_message('Invalid') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message }  
      end
    end

    describe "with valid info" do
      let(:user) { FactoryGirl.create(:user) }

      before do
        sign_in(user)
      end

      it { should have_title(user.name) }
      it { should show_profile_link }
      it { should reflect_signed_in }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Users',    href: users_path) }

      describe "followed by sign out" do
        before { click_link "Sign out" }

        it { should reflect_signed_out }
      end
    end
  end

  describe "authorization" do
    describe "for non-signed in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "in Users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }

          it { should reflect_signed_out }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }

          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the user index page" do
          before { visit users_path }
          it { should show_signin_page }
        end
      end

      describe "when attempting to access a protected page" do
        before do
          visit edit_user_path(user)    # redirects to signin page
          fill_in "Email",    with: user.email.upcase
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it { should show_edit_page }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }


      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }

        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }

        specify { expect(response).to redirect_to(root_url) }
      end

    end
  end
end
