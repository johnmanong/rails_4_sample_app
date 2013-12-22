require 'spec_helper'

describe "Static pages" do
  let(:title_base){ "Ruby on Rails Tutorial Sample  App" } 

  # Home Page tests
  describe "Home page" do
  	# ensure title copy is correct
  	it "should have the content 'Sample App'" do 		# description
  		visit '/static_pages/home'						# action
  		expect(page).to have_content('Sample App')		# requirement

    end
    it "should have base title" do 
    	visit '/static_pages/home'
  		expect(page).to have_title("#{title_base}") # will also do substring match
  	end

    it "should not have a custom page title" do
      visit '/static_pages/home'
      expect(page).not_to have_title(" | Home")
    end
  end

  # Help Page tests
  describe "Help Page" do
  	# ensure help appears in copy
  	it "shoud have the content 'Help'" do
  		visit '/static_pages/help'
  		expect(page).to have_content('Help')
  	end
  	it "should have the title 'Help'" do 
    	visit '/static_pages/help'
  		expect(page).to have_title("#{title_base} | Help") # will also do substring match
  	end
  end

  # About page tests
  describe "About page" do
  	it "should have content 'About Us'" do
  		visit '/static_pages/about'
  		expect(page).to have_content('About Us')
  	end
  # 	it "should have valid tutorial link" do 
		# tutorial_link = find(:css, "a:contains('Tutorial')")
  # 		tutorial_link.click
  # 		get page status, should be (200) or simply check
  # 	end
  	
    it "should have the title 'About'" do 
    	visit '/static_pages/about'
  		expect(page).to have_title("#{title_base} | About") # will also do substring match
  	end
  end

  #test for contact page (exercise)
  describe "Contact page" do
  	it "should have the title 'Contact'" do
  		visit '/static_pages/contact'
  		expect(page).to have_title("#{title_base} | Contact") #can also substring match
  	end

    it "it should have content 'Contact'" do
      visit '/static_pages/contact'
      expect(page).to have_content('Contact')
    end


  end

end
