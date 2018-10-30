# frozen_string_literal: true

# Validator for a cost_code on a SubProject (sub_cost_code)
# Uses Ubw::SubProject to look up the information from UBW
class SubCostCodeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    attribute_errors = record.errors[attribute]
    cost_code        = record.parent.cost_code
    return unless fetch_ubw_sub_project(value, attribute_errors)
    attribute_errors << I18n.t('errors.sub_project_inactive') if !ubw_sub_project.is_active?

    if ubw_sub_project.cost_code != cost_code
      attribute_errors << format(I18n.t('errors.sub_cost_code_parent_mismatch'), cost_code)
    end
  end

  private

  attr_reader :ubw_sub_project

  def fetch_ubw_sub_project(sub_cost_code, attribute_errors)
    begin
      @ubw_sub_project = Ubw::SubProject.find(sub_cost_code)
    rescue Ubw::Errors::NotFound
      attribute_errors << I18n.t('errors.sub_cost_code_not_found')
      false
    end
  end
end
