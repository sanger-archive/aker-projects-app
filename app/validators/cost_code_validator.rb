class CostCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Ubw::SubProject.where(cost_code: value).result_count.zero?
      record.errors[attribute] << I18n.t("errors.cost_code_not_found")
    end
  end
end