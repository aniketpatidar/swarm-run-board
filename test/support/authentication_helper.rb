# frozen_string_literal: true

module AuthenticationHelper
  def sign_in_as(email, password)
    visit "/sign_in"
    fill_in "Email address", with: email
    fill_in "Password", with: password
    click_on "Sign in"
  end
end
