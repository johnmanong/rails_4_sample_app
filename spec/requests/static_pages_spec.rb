require 'spec_helper'

describe "Static pages" do
  # Home Page tests
  describe "Home page" do
  	# ensure title copy is correct
  	it "should have the content 'Sample App'" do 		# description
  		visit '/static_pages/home'						# action
  		expect(page).to have_content('Sample App')		# requirement
    end
  end

  # Help Page tests
  describe "Help Page" do
  	# ensure help appears in copy
  	it "shoud have the content 'Help'" do
  		visit '/static_pages/help'
  		expect(page).to have_content('Help')
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
  	
  end

end
