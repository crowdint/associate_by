require 'test/unit'

require 'rubygems'
gem 'activerecord', '>=3.0.0.beta4'
require 'active_record'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :movies do |t|
      t.column :name, :string
    end

    create_table :actors do |t|
      t.column :movie_id, :integer
      t.column :name, :string
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Actor < ActiveRecord::Base
  belongs_to :movie
end

class Movie < ActiveRecord::Base
  has_many :actors
end

class AssociateByTest < Test::Unit::TestCase
  def setup
    setup_db
    @movie= Movie.create(:name => 'Movie')
    @actor= Actor.create(:name => 'Actor')
  end

  def teardown
    teardown_db
  end

  def test_has_many_association
    Movie.send(:associate_by, :actors, :name)
    @movie.actor_name = @actor.name
    @movie.save
    assert_equal(true, @movie.actors.include?(@actor))
  end

  def test_belongs_to_association
    Actor.send(:associate_by, :movie, :name)
    @actor.movie_name = @movie.name
    @actor.save
    assert_equal(@movie, @actor.movie)
  end

  def test_create_has_many_association
    Movie.send(:associate_by, :actors, :name, {:create => true})
    @movie.actor_name = 'A Different Actor'
    @movie.save
    assert_equal(1, Actor.where(:name => 'A Different Actor').count)
  end

  def test_create_belongs_to_association
    Actor.send(:associate_by, :movie, :name, {:create => true})
    @actor.movie_name = 'A Different Movie'
    @actor.save
    assert_equal(1, Movie.where(:name => 'A Different Movie').count)
  end

  def test_belongs_to_reader
    Actor.send(:associate_by, :movie, :name, {:create => true})
    @actor.movie = @movie
    assert_equal(@movie.name, @actor.movie_name)
  end

  def test_has_many_reader
    Movie.send(:associate_by, :actors, :name)
    @movie.actors << @actor
    assert_equal("", @movie.actor_name)
  end
end

