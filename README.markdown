# associate_by

This gem helps you associate two objects using a specified field.

Example:

    class Category < ActiveRecord::Base
      has_many :products
    end

    class Product < ActiveRecord::Base
      belongs_to :category
    end

You could assign a Product to a Category using the product name

## Instalation

### Rails 3

Add the gem to your Gemfile

    gem 'associate_by'

Install using bundle

    bundle install

## Usage

The parent class must have an association to the children class.

Just add to your parent class the following line:

    associate_by :product, :name

This code will create two instance methods on the Category object, product_name and product_name=

If we had the example we mentioned earlier, we're telling the gem that we want to associate the 
Product with the Category using the Product name.

Example:
    c = Category.create(:name => "Parent")
    p = Product.create(:name => "Child")
    
    c.product_name = "Child"
    
It will associate the Category with the Product so, 

    c.products # => [p]

## Todo

Finish this document