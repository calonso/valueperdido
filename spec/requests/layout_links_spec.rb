require 'spec_helper'

describe "LayoutLinks" do
  it "should have a Home page at '/'" do
    get root_path
    response.should have_selector('title', :content => 'Home')
  end

  it "should have a Terms page at '/terms'" do
    get terms_path
    response.should have_selector('title', :content => 'Terms and Conditions')
  end
end
