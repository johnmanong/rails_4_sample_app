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
      it { should_not show_profile_link }
      it { should_not show_settings_link }
      
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
      it { should show_settings_link }
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
      
      describe "in the Relationships controller" do
        describe "submitting a create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting a destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end


      describe "in the Microposts controller" do
        describe "submitting to the create action" do
          # note plural in path
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destory action" do
          # note singular in path
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

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

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should show_signin_page }
        end

        describe "visiting the follower page" do
          before { visit followers_user_path(user) }
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
          it { should reflect_signed_in }
          it { should show_edit_page }

          describe "when signing in again" do
            before do
              click_link 'Sign out'
              sign_in user
            end

            it "should render default (profile) page" do
              expect(page).to reflect_signed_in
              expect(page).to show_profile_page
            end
          end
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
