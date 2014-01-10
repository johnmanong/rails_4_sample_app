RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

# Cannot import ActionView::Helpers::TextHelpers
#
RSpec::Matchers.define :have_this_many_errors do |num|
  match do |page|
    msg = num == 1 ? 'error' : 'errors'
    expect(page).to have_content("#{num} #{msg}")
  end
end
