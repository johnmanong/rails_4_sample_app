RSpec::Matchers.define :show_profile_link do
  match do |page|
    expect(page).to have_link('Profile', href: user_path(user))
  end
end

RSpec::Matchers.define :show_profile_page do
  match do |page|
    # it { should have_content('Sign up') }
    expect(page).to have_title(user.name)
  end
end

RSpec::Matchers.define :show_signup_page do
  match do |page|
    # it { should have_content(user.name) }
    expect(page).to have_title(full_title('Sign up'))
  end
end

RSpec::Matchers.define :show_edit_page do
  match do |page|
    expect(page).to have_selector('h1', text: 'Update your profile')
  end
end