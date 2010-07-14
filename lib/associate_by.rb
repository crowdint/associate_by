module AssociateBy
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def associate_by(association, method)
      define_method("#{association.to_s.singularize}_#{method}") do
        ""
      end

      define_method("#{association.to_s.singularize}_#{method}=") do |value|
        object = association.to_s.singularize.camelize.constantize.where(["#{method} = ?", value]) unless value.nil?
        if object
          send(association) << object
        end
      end
    end
  end
end

class ActiveRecord::Base
  include AssociateBy
end