class IdentityValidator < ActiveModel::Validator
  attr_reader :attribute

  def validate(record)
    raise NotImplementedError, "IdentityValidator#validator is an abstract method and needs to be overridden"
  end

  def attribute
    @attribute ||= options[:attribute]
  end

  def value(record)
    record.send(attribute) if attribute.present? && record.respond_to?(attribute.to_sym)
  end
end