require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after login" do
    user = Factory(:user, :validated => true)
    visit edit_user_path(user, :locale => :en)
    # Test automatically follows the redirect to the login page
    fill_in :Email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    # The test follows the redirect again, now to users/edit
    response.should render_template('users/edit')
  end
end
