# associate_by

This gem helps you associate two objects using a specified field.

*WARNING: This gem only works with Rails 3. It might work with Rails 2, but I haven't tried it.*

Example:

    class Category < ActiveRecord::Base
      has_many :products
      associate_by :products, :name
    end

    class Product < ActiveRecord::Base
      belongs_to :category
      associate_by :category, :name
    end

You could associate a Product with a Category using the product name in a Category instance, or using the Category name on a Product instance.

It is not necessary to use it on both models.

## Instalation

### Rails 3

Add the gem to your Gemfile

    gem 'associate_by', '>=0.1.1'

Install using bundle

    bundle install

## Usage

The parent class must have an association to the children class.

Just add to your parent class the following line:

    associate_by :product, :name

This code will create two instance methods on the Category object, product_name and product_name=

You can also include a :create option and the gem will create the associated object if it doesn't exist.

    class Category < ActiveRecord::Base
      has_many :products
      associate_by :products, :name
    end

    class Product < ActiveRecord::Base
      belongs_to :category
      associate_by :category, :name, :create
    end

    p = Product.create(:name => 'A New Product')
    p.category_name = 'A New Category'

In this example, if the Category doesn't exist yet, it will be created

### The writer

If we had the example we mentioned earlier, we're telling the gem that we want to associate the 
Product with the Category using the Product name.

Example:
    c = Category.create(:name => "Parent")
    p = Product.create(:name => "Child")
    
    c.product_name = "Child"
    
It will associate the Category with the Product so, 

    c.products #=> [p]

### The reader

#### belongs_to

If the association is not an one-to-many association, it returns the value of the parent object, so:

Given that,

    c = Category.create(:name => "Parent")
    p = Product.create(:name => "Child")
    
    p.category = c

Then,

    p.category_name #=> "Parent"

If you have it defined on both moder
#### has_many, habtm

In this case, the reader always returns an empty string, so

Given that,

    c = Category.create(:name => "Parent")
    p = Product.create(:name => "Child")

    p.category = c

Then,
    
    c.product_name #=> ""

Always.

## Why?

Think about a typical CRUD, where you click on "New Something", then you're taken to a form, you fill the form, click the "Create" button, then you're taking to the show action, and so on.

If you have a lot of catalogs in your app, that are only used to store one field, typically, just a name, then, it's going to be hell for the user to set up new values.

From a usability perspective, it would be nicer if the index page just showed a text field with a "Create" button and you could quickly create new items for the list.

This plays very well with a form, specially for create situations.

    form_for @product do |f|
      f.text_field :category_name
      f.submit 'Create'

Pour some [autocomplete into the mix](http://github.com/crowdint/rails3-jquery-autocomplete) and you will end up with a very easy way to fill your catalogs.

## Todo

* Handle errors via Rails, for example, when the associated object doesn't exist and :create => false
* The writer for the x-to-many associations can receive an array like: category.products = ["Product 1", "Product 2", "Product 3"]
* Make it more semantic, like: associate_with :product, :by => :name
* Finish this document
