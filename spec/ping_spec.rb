require 'spec_helper'

describe 'App is alive' do
  it 'verifies root is up' do
    visit '/'
    page.should have_content "It's alive"
  end
end
