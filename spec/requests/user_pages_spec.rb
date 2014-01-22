require 'spec_helper'

describe "UserPages" do
  subject { page }

  describe "index page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in FactoryGirl.create(:user)
      visit users_path
    end

    it { should have_content('All users')}
    it { should have_title(full_title('All users')) }

    describe "pagination" do
      let(:first_page_users) { User.paginate(page: 1) }
      before(:all) { 40.times { FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }

      it { should have_selector("div.pagination") }

      it "should list each user" do
        first_page_users.each do |u|
          expect(page).to have_selector('li', text: u.name)
        end
      end

      it "should not list users page first page" do
        expect(first_page_users.length).to eq(30)   # 30 is default pagination value from gem
      end
    end

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete a user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: users_path(admin)) }
      end

      describe "as non-admin user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }

        before do
          sign_in non_admin, no_capybara: true

          describe "submitting a DELETE request should fail" do
            before { delete user_path(user) }
            specify { expect(response).to redirect_to(root_url) }
          end


        end

      end

    end

  end

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
    before {
      sign_in(user)
      visit edit_user_path(user) 
    }
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

    describe "valid info" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button 'Save changes'
      end

      it { should show_profile_page }
      it { should have_success_message }
      it { should reflect_signed_in }
      specify { expect(user.reload.name).to eq(new_name) }
      specify { expect(user.reload.email).to eq(new_email) }
    end

    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true,
                  password: user.password,
                  password_confirmation: user.password } }
      end

      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end

  end
end
