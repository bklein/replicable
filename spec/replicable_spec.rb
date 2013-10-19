require 'spec_helper'
require 'pry'

describe Replicable do

  def reset_models
    # reset all settings each time
    [Ship, Pirate, Parrot].each do |model|
      model.attr_replicable
      model.has_many_replicable
      model.has_one_replicable
    end
  end

  before :all do
    Pirate.send :include, Replicable
  end

  describe ".attr_replicable" do
    let(:attributes) { [:name, :age] }
    before :each do
      Pirate.attr_replicable(*attributes)
    end

    it "adds attributes as attr_accessible as: :replicable" do
      Pirate.accessible_attributes(:replicable).to_a.map(&:intern).should include(*attributes)
    end

    it "does not add attributes to attr_acessible as: :default" do
      Pirate.accessible_attributes.to_a.map(&:intern).should_not include(*attributes)
    end

    it "defines #replicable_attributes" do
      Pirate.new.should respond_to :replicable_attributes
      Pirate.new.replicable_attributes.should =~ attributes
    end

  end

  describe ".has_many_replicable" do
    before :each do
      Ship.has_many_replicable :pirates
    end

    it "accepts_nested_attributes_for the replicable collection" do
      Ship.nested_attributes_options.keys.should include(:pirates)
    end

    it "adds collection_attributes to attr_acessible as: :replicable" do
      Ship.accessible_attributes(:replicable).to_a.map(&:intern).should include(:pirates_attributes)
    end

    it "does not add collection_attributes to attr_acessible as: :default" do
      Ship.accessible_attributes(:default).to_a.map(&:intern).should_not include(:pirates_attributes)
    end

    it "defines #replicable_one_to_many_associations" do
      Ship.new.should respond_to :replicable_one_to_many_associations
      Ship.new.replicable_one_to_many_associations.should =~ [:pirates]
    end

  end

  describe ".has_one_replicable" do
    before :each do
      Pirate.has_one_replicable :parrot
    end

    it "accepts_nested_attributes_for the replicable association" do
      Pirate.nested_attributes_options.keys.should include(:parrot)
    end

    it "adds association_attributes to attr_acessible as: :replicable" do
      Pirate.accessible_attributes(:replicable).to_a.map(&:intern).should include(:parrot_attributes)
    end

    it "does not add association_attributes to attr_acessible as: :default" do
      Pirate.accessible_attributes.to_a.map(&:intern).should_not include(:parrot_attributes)
    end

    it "defines #replicable_one_to_one_associations" do
      Pirate.new.should respond_to :replicable_one_to_one_associations
      Pirate.new.replicable_one_to_one_associations.should =~ [:parrot]
    end

  end

  describe "#replicate_as_json" do
    
    before :each do
      reset_models
    end

    it "produces a hash of of the model's attributes" do
      Pirate.attr_replicable :name, :age
      pirate = Pirate.create! do |p|
        p.name = "Blackbeard"
        p.age = 42
      end

      expected_json = {
        "name" => "Blackbeard",
        "age"  => 42
      }
      pirate.replicate_as_json.should eq expected_json
    end

    it "produces a hash of of the model's one_to_many associations" do
      Ship.has_many_replicable :pirates
      Pirate.attr_replicable :name, :age

      ship = Ship.create! do |s|
        s.name = "Magestic Sea"
      end
      3.times do |n|
        ship.pirates.create!.tap do |p|
          p.name = "Blackbeard Clone #{ n }"
          p.age = n
        end
      end

      expected_json = {
        "pirates_attributes" => [
          {
            "name" => "Blackbeard Clone 0",
            "age"  => 0
          },
          {
            "name" => "Blackbeard Clone 1",
            "age"  => 1
          },
          {
            "name" => "Blackbeard Clone 2",
            "age"  => 2
          }
        ]
      }

      ship.replicate_as_json.should eq expected_json
    end

    it "produces a hash of of the model's one_to_one associations" do
      Parrot.attr_replicable :name, :color
      Pirate.has_one_replicable :parrot

      pirate = Pirate.create!.tap do |p|
        p.name = "Blackbeard"
        p.age = 42
      end

      pirate.create_parrot!.tap do |p|
        p.name = "Sam the Parrot"
        p.color = "Burnt Sienna"
      end

      expected_json = {
        "parrot_attributes" => {
          "name" => "Sam the Parrot",
          "color" => "Burnt Sienna"
        }
      }

      pirate.replicate_as_json.should eq expected_json

    end

    it "produces a nested hash of everything" do
      Ship.attr_replicable :name
      Ship.has_many_replicable :pirates

      Pirate.attr_replicable :name, :age
      Pirate.has_one_replicable :parrot

      Parrot.attr_replicable :name, :color

      ship = Ship.create!.tap do |s|
        s.name = "Magestic Sea"
      end

      10.times do |n|
        ship.pirates.create!.tap do |p|
          p.name = "Blackbeard Clone #{ n }"
          p.age = n
          p.create_parrot!.tap do |bird|
            bird.name = "Ex-parrot for Blackbeard Clone #{ n }"
            bird.color = "Burnt Sienna"
          end
        end
      end

      expected_json = {
        "name"=>"Magestic Sea",
        "pirates_attributes"=>
        [
          {"name"=>"Blackbeard Clone 0",
           "age"=>0,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 0", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 1",
           "age"=>1,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 1", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 2",
           "age"=>2,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 2", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 3",
           "age"=>3,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 3", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 4",
           "age"=>4,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 4", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 5",
           "age"=>5,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 5", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 6",
           "age"=>6,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 6", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 7",
           "age"=>7,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 7", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 8",
           "age"=>8,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 8", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 9",
           "age"=>9,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 9", "color"=>"Burnt Sienna"}}
        ]
      }

      ship.replicate_as_json.should eq expected_json
    end

  end

  describe "#replicate_from_json" do
    before :each do
      reset_models
    end

    it "instantiates attributes from hash" do
      Pirate.attr_replicable :name, :age
      json = {
        "name" => "Reborn Blackbeard",
        "age" => 12
      }
      pirate = Pirate.new.replicate_from_json json
      pirate.name.should eq "Reborn Blackbeard"
      pirate.age.should eq 12
    end

    it "builds one_to_one association from hash" do
      Pirate.has_one_replicable :parrot
      Parrot.attr_replicable :name, :color
      json = {
        "parrot_attributes" => {
          "name" => "Samuel",
          "color" => "Cerulean Frost"
        }
      }

      pirate = Pirate.new.replicate_from_json json
      pirate.parrot.should be_present
      pirate.parrot.name.should eq "Samuel"
      pirate.parrot.color.should eq "Cerulean Frost"
    end

    it "builds one_to_many collection from hash" do
      Ship.has_many_replicable :pirates
      Pirate.attr_replicable :name, :age
      json = {
        "pirates_attributes" => [
          { "name" => "Blackbeard", "age" => 42 },
          { "name" => "Redbeard", "age" => 314 },
          { "name" => "Bluebeard", "age" => 2 }
        ]
      }

      ship = Ship.new.replicate_from_json json

      ship.pirates.should be_present
      ship.pirates.length.should eq 3

      ship.pirates[0].name.should eq "Blackbeard"
      ship.pirates[0].age.should eq 42
      ship.pirates[1].name.should eq "Redbeard"
      ship.pirates[1].age.should eq 314
      ship.pirates[2].name.should eq "Bluebeard"
      ship.pirates[2].age.should eq 2
    end

    it "builds nested models from nested hashes" do
      Ship.attr_replicable :name
      Ship.has_many_replicable :pirates

      Pirate.attr_replicable :name, :age
      Pirate.has_one_replicable :parrot

      Parrot.attr_replicable :name, :color

      json = {
        "name"=>"Magestic Sea",
        "pirates_attributes"=>
        [
          {"name"=>"Blackbeard Clone 0",
           "age"=>0,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 0", "color"=>"Burnt Sienna"}},
          {"name"=>"Blackbeard Clone 1",
           "age"=>1,
           "parrot_attributes"=> {"name"=>"Ex-parrot for Blackbeard Clone 1", "color"=>"Chartreuse"}}
        ]
      }

      ship = Ship.new.replicate_from_json json

      ship.name.should eq "Magestic Sea"
      ship.pirates.should be_present
      ship.pirates.first.tap do |first_pirate|
        first_pirate.name.should eq "Blackbeard Clone 0"
        first_pirate.age.should eq 0
        first_pirate.parrot.should be_present
        first_pirate.parrot.tap do |p|
          p.name.should eq "Ex-parrot for Blackbeard Clone 0"
          p.color.should eq "Burnt Sienna"
        end
      end
      ship.pirates.last.tap do |last_pirate|
        last_pirate.name.should eq "Blackbeard Clone 1"
        last_pirate.age.should eq 1
        last_pirate.parrot.should be_present
        last_pirate.parrot.tap do |p|
          p.name.should eq "Ex-parrot for Blackbeard Clone 1"
          p.color.should eq "Chartreuse"
        end
      end
    end

  end

  describe "#replicate" do

  end

  describe "#replicate!" do

  end

end
