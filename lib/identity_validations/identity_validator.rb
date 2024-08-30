module IdentityValidations
  class IdentityValidator < ActiveModel::Validator
    attr_writer :attribute

    def validate(record)
      raise NotImplementedError, "IdentityValidator#validator is an abstract method and needs to be overridden"
    end

    def attribute
      @attribute ||= options[:attribute]
    end

    # I was tempted to make `record` an instance variable with an accessor, but that could
    # cause problems with how Rails instantiates and reuses validator instances
    def get_attribute(record)
      return unless attribute.present?
      if !record.respond_to?(attribute.to_sym)
        raise ArgumentError, "IdentityValidator: attribute '#{attribute}' not found in class #{record.class}"
      end
      record.send(attribute) 
    end
  end
end
