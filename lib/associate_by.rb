module AssociateBy

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def associate_by(association, method, options = {})
      attr_writer "#{association.to_s.singularize}_#{method}"

      define_method("#{association.to_s.singularize}_#{method}") do
        begin
          instance_variable_get("@#{association.to_s.singularize}_#{method}") || self.send("#{association.to_s}")[method]
        rescue
          ""
        end
      end
      
      define_method("#{association.to_s.singularize}_#{method}_create?", lambda { options[:create] || false} )

      define_method("before_save_for_#{association.to_s.singularize}_#{method}") do
        object = association.to_s.singularize.camelize.constantize.where(["#{method} = ?", self.send("#{association.to_s.singularize}_#{method}")]).first

        # If the object doesn't exist and the parameter create is true, then create it
        if object.nil? && !(self.send("#{association.to_s.singularize}_#{method}").empty?) && self.send("#{association.to_s.singularize}_#{method}_create?")
          object = association.to_s.singularize.camelize.constantize.create({"#{method}" => self.send("#{association.to_s.singularize}_#{method}")})
        end

        if object
          if self.send("#{association.to_s}").is_a?(Array)
            self.send("#{association.to_s}") << object
          else
            self.send("#{association.to_s.singularize}=", object)
          end
        end
      end

      before_save "before_save_for_#{association.to_s.singularize}_#{method}"
    end
  end
end


class ActiveRecord::Base
  include AssociateBy
end