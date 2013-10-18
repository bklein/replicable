require 'active_record'
require 'replicable'

# Establish memory sqlite3 db and create tables for test models

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :ships, force: true do |t|
    t.string :name
    t.timestamps
  end

  create_table :pirates, force: true do |t|
    t.string :name
    t.integer :age
    t.integer :ship_id
    t.timestamps
  end

  create_table :parrots, force: true do |t|
    t.string :name
    t.string :color
    t.integer :pirate_id
  end

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
