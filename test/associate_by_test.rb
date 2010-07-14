require 'test/unit'

require 'rubygems'
gem 'activerecord', '>=3.0.0.beta4'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :parents do |t|
      t.column :name, :string
    end

    create_table :children do |t|
      t.column :parent_id, :integer
      t.column :name, :string
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Category < ActiveRecord::Base
  has_many :products
  associate_by :products, :name

  def self.table_name 
    "parents"
  end
end

class Product < ActiveRecord::Base
  associate_by :category, :name
  belongs_to :category

  def self.table_name 
    "children"
  end
end

class Actor < ActiveRecord::Base
  associate_by :movie, :name, :create => true
  belongs_to :movie

  def self.table_name 
    "children"
  end
end

class Movie < ActiveRecord::Base
  associate_by :actors, :name, :create => true
  has_many :actors

  def self.table_name 
    "parents"
  end
end

class AssociateByTest < Test::Unit::TestCase
  def setup
    setup_db
    @category = Category.create(:name => 'Category')
    @product = Product.create(:name => 'Product')
    @movie= Movie.create(:name => 'Movie')
    @actor= Actor.create(:name => 'Actor')
  end

  def teardown
    teardown_db
  end

  def test_has_many_association
    @category.product_name = @product.name
    @category.save
    assert_equal(true, @category.products.include?(@product))
  end

  def test_belongs_to_association
    @product.category_name = @category.name
    @product.save
    assert_equal(@category, @product.category)
  end

  def test_create_has_many_association
    @movie.actor_name = 'A Different Actor'
    @movie.save
    assert_equal(1, Actor.where(:name => 'A Different Actor').count)
  end

  def test_create_belongs_to_association
    @actor.movie_name = 'A Different Movie'
    @actor.save
    assert_equal(1, Movie.where(:name => 'A Different Movie').count)
  end
  
  def test_belongs_to_reader
    @product.category = @category
    @product.save
    assert_equal(@category.name, @product.category_name)
  end
  
  def test_has_many_reader
    @category.products << @product
    assert_equal("", @category.product_name)
  end
end

