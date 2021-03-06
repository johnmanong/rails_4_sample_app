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
        it { should_not have_link('delete', href: users_path(admin)) }

        it "should be able to delete a user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end

        describe "delete action without link" do
          before do
            sign_in admin, no_capybara: true
          end

          it "should not be able to delete themselves" do
            expect do
              delete user_path(admin)
            end.not_to change(User, :count).by(-1)
          end

        end
      end

      describe "as non-admin user" do
        let(:user) { FactoryGirl.create(:user) }
        let(:non_admin) { FactoryGirl.create(:user) }

        before do
          sign_in non_admin, no_capybara: true
        end

        describe "submitting a DELETE request should fail" do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
    end
  end

  describe "following/unfollowing" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }
    
    describe "followed users" do
      before do
        sign_in user
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do
      before do
        sign_in other_user
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end

  describe "profile page" do
    # create user model object
    let(:user) { FactoryGirl.create(:user) }
    # create some associated microposts 
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: 'foo') }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: 'bar') }

    before { visit user_path(user) }

    it { should show_profile_page }

    describe "following/followers stats" do
      let(:other_user) { FactoryGirl.create(:user) }
        before  do
          other_user.follow!(user)
          visit user_path(other_user)
        end

      it { should have_link("1 following", href: following_user_path(other_user)) }
      it { should have_link("0 followers", href: followers_user_path(other_user)) }
    end
    


    describe "following/unfollowing buttons" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following a user" do
        before { visit user_path(other_user) }

        it "should increment user's following count by one" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end

        it "should increment other user's followers count by one" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        describe "toggling button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          visit user_path(other_user)
          click_button "Follow"
        end

        it "should decrement user's following count by one" do
          expect do
            click_button 'Unfollow'
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement other user's followers count by one" do
          expect do
            click_button 'Unfollow'
          end.to change(other_user.followers, :count).by(-1)
        end


        describe "toggling button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end

      end

    end

    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
      it { should_not have_selector('a', text: 'delete')}
    end

    describe "no microposts" do
      before do
        user.microposts.delete_all
        visit user_path(user)
      end

      it { should have_content("No Microposts yet")}
    end

    describe "signed in user" do
      before { sign_in user }

      describe "visit own profile" do
        before { visit user_path(user) }

        it { should have_selector("ol.microposts li a", text: "delete") }
      end

      describe "visit anothers profile" do
        let(:another_user) { FactoryGirl.create(:user) }
        let!(:m3) { FactoryGirl.create(:micropost, user: another_user, content: 'baz') }
        let!(:m4) { FactoryGirl.create(:micropost, user: another_user, content: 'raz') }

        before { visit user_path(another_user) }

        it { should_not have_selector("ol.microposts li a", text: "delete") }
      end
    end
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

    describe "when a user is signed in" do
      before { sign_in FactoryGirl.create(:user), no_capybara: true}

      describe "submitting GET to signup path should fail" do
        before { get signup_path }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting POST to signup path should fail" do
        let(:params) { { user: { name:      'some name',
                                 email:     'email@example.com',
                                 password:  'foobar',
                                 password_confirmation: 'foobar' } } }
        before { post users_path, params }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before {
      sign_in user
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
