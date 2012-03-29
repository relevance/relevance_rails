require 'spec_helper'

describe 'App is alive', :js => true do
  it 'verifies root is up' do
    visit '/'
    page.should have_content "It's alive"
  end

  it 'verifies coffeescript served up as js' do
    visit '/assets/relevance_rails.js'
    page.should have_content "console.log('Hello from Relevance, Inc!');"
  end

  it "verifies haml is served up" do
    visit '/relevance_rails'
    page.should have_content 'WELCOME HOME'
  end

  it "verifies scss is served up as css" do
    visit '/assets/relevance_rails.css'
    page.should have_content "background-color: blue;"
  end
end
