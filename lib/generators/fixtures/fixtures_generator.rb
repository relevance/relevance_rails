class FixturesGenerator < Rails::Generators::Base
  def create_controller
    create_file "app/controllers/relevance_rails_controller.rb", <<-STR
class RelevanceRailsController < ApplicationController
end
STR
  end

  def create_view
    create_file "app/views/relevance_rails/index.html.haml", <<-STR
%h1 WELCOME HOME
STR
  end

  def create_coffee
    create_file "app/assets/javascripts/relevance_rails.js.coffee", <<-STR
console.log 'Hello from Relevance, Inc!'
STR
  end

  def create_sass
    create_file "app/assets/stylesheets/relevance_rails.css.scss", <<-STR
$background: blue;

h1.relevance {
    background-color: $background;
    }
STR
  end

  def modify_routes
    insert_into_file "config/routes.rb", :after => "::Application.routes.draw do" do
      %[\n  # Required to test relevance_rails gem.\n  match '/relevance_rails' => 'relevance_rails#index'\n]
    end
  end
end
