include ApplicationHelper

def sign_in(user, options = {})
  if options[:no_capybara]
    # sign in when no using capybara
    # cookies.permanent is not available here
    token = User.new_remember_token
    cookies[:remember_token] = token
    user.update_attribute(:remember_token, User.encrypt(token)) 
  else
    visit signin_path
    fill_in "Email",    with: user.email.upcase
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def fill_in_valid_sign_up_info
  fill_in "Name",         with: "Example User"
  fill_in "Email",        with: "user@example.com"
  fill_in "Password",     with: "foobar"
  fill_in "Confirmation", with: "foobar"
end


# Assumes sign in and sign out links are mutually exclusive
#
RSpec::Matchers.define :reflect_signed_in do
  match do |page|
    # expect(page).not_to have_link('Sign in', href: signin_path)
    expect(page).to     have_link('Sign out', href: signout_path)
  end
end

RSpec::Matchers.define :reflect_signed_out do
  match do |page|
    expect(page).to     have_link('Sign in', href: signin_path)
    # expect(page).not_to have_link('Sign out', href: signout_path)
  end
end
