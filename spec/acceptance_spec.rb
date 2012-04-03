require 'spec_helper'

describe 'App is alive', :js => true do
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

  it "verifies a working database connection" do
    visit '/relevance_rails/db'
    within ('h1.database') do
      page.should have_content '_development'
    end
  end
end
