class FixturesGenerator < Rails::Generators::Base
  def create_controller
    create_file "app/controllers/relevance_rails_controller.rb", <<-STR
class RelevanceRailsController < ApplicationController
end
STR
  end

  def create_views
    create_file "app/views/relevance_rails/index.html.haml", <<-STR
%h1 WELCOME HOME
STR
    create_file "app/views/relevance_rails/db.html.haml", <<-STR
= conn = ActiveRecord::Base.connection
= results = conn.execute("select 4200+42 as advanced_math")
%h1.advanced_math= results.first["advanced_math"]
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
      <<-STR

  # Required to test relevance_rails gem.
  match '/relevance_rails' => 'relevance_rails#index'
  match '/relevance_rails/db' => 'relevance_rails#db'
STR
    end
  end
end
