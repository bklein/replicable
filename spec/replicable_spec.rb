require 'spec_helper'
require 'pry'

describe Replicable do

  before :all do
    Pirate.send :include, Replicable
  end

  describe ".attr_replicable" do

    it "adds attributes as attr_accessible as: :replicable" do
      Pirate.attr_replicable(:name, :age)
      Pirate.attr_accessible[:replicable].to_a.map(&:intern).should =~ [:name, :age]
    end

    it "does not add attributes to attr_acessible as: :default" do
      Pirate.attr_replicable(:name, :age)
      Pirate.attr_accessible[:default].to_a.map(&:intern).should_not =~ [:name, :age]
    end

    it "defines #replicable_attributes" do
      Pirate.attr_replicable(:name)
      Pirate.new.respond_to?(:replicable_attributes).should be_true
    end

  end

  describe ".has_many_replicable" do

  end

  describe ".has_one_replicable" do

  end

  describe "#replicate_as_json" do

  end

  describe "#replicate_from_json" do

  end

  describe "#replicate" do

  end

  describe "#replicate!" do

  end

end
