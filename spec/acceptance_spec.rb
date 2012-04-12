require 'spec_helper'

describe 'App is alive', :js => true, :acceptance => true do
  it "verifies haml is served up" do
    visit '/relevance_rails'
    page.should have_content 'WELCOME HOME'
  end

  it 'verifies coffeescript served up as js' do
    visit '/assets/application.js'
    page.should have_content 'console.log("Hello from Relevance, Inc!")'
  end

  it "verifies scss is served up as css" do
    visit '/assets/application.css'
    page.should have_content "background-color:blue"
  end

  it "verifies a working database connection" do
    visit '/relevance_rails/db'
    within ('h1.advanced_math') do
      page.should have_content '4242'
    end
  end
end
