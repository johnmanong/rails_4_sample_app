require 'spec_helper'

describe "Static pages" do
  let(:title_base){ "Ruby on Rails Tutorial Sample  App" } 

  subject { page }

  # Home Page tests
  describe "Home page" do
    before {
      visit root_path
    }

    it { should have_content('Sample App') }
    it { should have_title(full_title('')) }
    it { should_not have_title(" | Home") }

  	# # ensure title copy is correct
  	# it "should have the content 'Sample App'" do 		# description
  	# 	expect(page).to have_content('Sample App')		# requirement
   #  end
   #  it "should have base title" do 
  	# 	expect(page).to have_title("#{title_base}") # will also do substring match
  	# end

   #  it "should not have a custom page title" do
   #    expect(page).not_to have_title(" | Home")
   #  end
  end

  # Help Page tests
  describe "Help Page" do
    before {
      visit help_path
    }

    # ensure help appears in copy
    it { should have_content('Help') }
		it { should have_title("#{title_base} | Help") } # will also do substring match
  end

  # About page tests
  describe "About page" do
    before {
      visit about_path
    }

    it { should have_content('About Us') }
    it { should have_title("#{title_base} | About") } # will also do substring match
    

  # 	it "should have valid tutorial link" do 
		# tutorial_link = find(:css, "a:contains('Tutorial')")
  # 		tutorial_link.click
  # 		get page status, should be (200) or simply check
  # 	end
  	
  end

  #test for contact page (exercise)
  describe "Contact page" do
    before {
      visit contact_path
    }

    it { should have_title("#{title_base} | Contact") } #can also substring match
    it { should have_content('Contact') }

  end

end
