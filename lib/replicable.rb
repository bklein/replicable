require "replicable/version"

module Replicable

  def self.included(base)
    base.extend ClassMethods
    base.send :include, ::Replicable::InstanceMethods
  end

  module ClassMethods

    def attr_replicable *attributes
      define_method :replicable_attributes do
        attributes
      end
      attr_accessible(*attributes, as: :replicable)
    end

    def has_many_replicable *one_to_many_associations
      define_method :replicable_one_to_many_associations do
        one_to_many_associations
      end
      attr_accessible(*one_to_many_associations.map{|association| "#{ association }_attributes" }, as: :replicable)
      one_to_many_associations.each do |association|
        unless new.respond_to? "#{ association }_attributes".to_sym
          accepts_nested_attributes_for association
        end
      end
    end

    def has_one_replicable *one_to_one_associations
      define_method :replicable_one_to_one_associations do
        one_to_one_associations
      end
      attr_accessible(*one_to_one_associations.map{|association| "#{ association }_attributes" }, as: :replicable)
      one_to_one_associations.each do |association|
        unless new.respond_to? "#{ association }_attributes".to_sym
          accepts_nested_attributes_for association
        end
      end
    end

  end

  module InstanceMethods

    def replicate_as_json
      json = {}

      if respond_to? :replicable_attributes
        replicable_attributes.each do |attr|
          json[attr.to_s] = self.send attr.to_sym
        end
      end

      if respond_to? :replicable_one_to_many_associations
        replicable_one_to_many_associations.each do |has_many|
          association = self.send(has_many.to_sym)
          if association.present? && association.first.respond_to?(:replicate_as_json)
            json["#{ has_many }_attributes"] = association.map(&:replicate_as_json)
          end
        end
      end

      if respond_to? :replicable_one_to_one_associations
        replicable_one_to_one_associations.each do |has_one|
          association = self.send(has_one.to_sym)
          if association.present? && association.respond_to?(:replicate_as_json)
            json["#{ has_one }_attributes"] = association.send(:replicate_as_json)
          end
        end
      end

      json
    end

    def replicate_from_json(json)
      assign_attributes json, as: :replicable
      self
    end

    def replicate
      new_record = self.class.new self.replicate_as_json, as: :replicable
      new_record
    end

    def replicate!
      new_record = replicate
      new_record.save!
      new_record
    end

  end

end
