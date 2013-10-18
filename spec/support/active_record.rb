require 'active_record'
require 'replicable'

# Establish memory sqlite3 db and create tables for test models

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Migration.create_table :pirates do |t|
  t.string :name
  t.integer :age
  t.integer :ship_id
  t.timestamps
end

ActiveRecord::Migration.create_table :ships do |t|
  t.string :name
  t.timestamps
end

ActiveRecord::Migration.create_table :parrots do |t|
  t.string :name
  t.string :color
  t.integer :pirate_id
end

class Ship < ActiveRecord::Base
  include Replicable
  has_many :pirates
end

class Pirate < ActiveRecord::Base
  include Replicable
  belongs_to :ship
  has_one :parrot
end

class Parrot < ActiveRecord::Base
  include Replicable
  belongs_to :pirate
end
