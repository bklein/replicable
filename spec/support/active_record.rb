require 'active_record'

# Establish memory sqlite3 db and create tables for test models

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

ActiveRecord::Migration.create_table :foo do |t|
  t.string :string_value
  t.integer :integer_value
  t.decimal :complex_value
  t.boolean :boolean_value
  t.datetime :datetime_value
  t.timestamps
end

ActiveRecord::Migration.create_table :bar do |t|
  t.string :string_value
  t.integer :integer_value
  t.decimal :complex_value
  t.boolean :boolean_value
  t.datetime :datetime_value
  t.integer :foo_id
  t.timestamps
end


ActiveRecord::Migration.create_table :baz do |t|
  t.string :string_value
  t.integer :integer_value
  t.decimal :complex_value
  t.boolean :boolean_value
  t.datetime :datetime_value
  t.integer :bar_id
  t.timestamps
end
