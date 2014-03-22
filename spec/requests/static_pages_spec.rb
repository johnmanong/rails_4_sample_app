require 'spec_helper'

describe "Static pages" do
  let(:title_base){ "Ruby on Rails Tutorial Sample  App" } 

  subject { page }

  # these tests are shared between all subsequent tests
  shared_examples_for 'all static pages' do
    it { should have_selector('h1', text: heading) }  # checks for html el and text
    it { should have_title(full_title(page_title)) }  # will also do substring match
  end

  # Home Page tests
  describe "Home page" do
    before { visit root_path }

    let(:heading) { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like 'all static pages'
    it { should_not have_title(" | Home") }

    describe "for signed in user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before  do
          other_user.follow(user)
          visit root_path
        end
        it { should have_link("0 following", href: following_users_path(user)) }
        it { should have_link("1 followers", href: followers_users_path(user)) }
      end

      it "should show correct text than one microposts" do
        expect(page).to have_content("2 microposts")
      end

      it "should handle 1 micropost" do
        user.feed.first.delete
        visit root_path
        expect(page).to have_content("1 micropost")
      end

      it "should show special message for no posts" do
        user.feed.delete_all
        visit root_path
        expect(page).to have_content("0 microposts")
      end

      it "should show correct number of microposts" do
        40.times do 
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        end
        visit root_url

        expect(page.all("ol.microposts li").count).to eq(30)
      end
    end

  end

  # Help Page tests
  describe "Help Page" do
    before { visit help_path }

    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }   

    it_should_behave_like 'all static pages'

  end

  # About page tests
  describe "About page" do
    before { visit about_path }

    let(:heading) { 'About Us' }
    let(:page_title) { 'About' }

    it_should_behave_like 'all static pages'

  end

  #test for contact page (exercise)
  describe "Contact page" do
    before { visit contact_path }

    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }            

    it_should_behave_like 'all static pages'

  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end

end
