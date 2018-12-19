# frozen_string_literal: true

# Validator for a Project Cost Code
# It just has to exist in UBW right now
class CostCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless Ubw::SubProject.where(cost_code: value).result_count.zero?
    record.errors[attribute] << I18n.t('errors.cost_code_not_found')
  end
end
