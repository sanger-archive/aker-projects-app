# Validator for a cost_code on a SubProject (sub_cost_code)
# Uses Ubw::SubProject to look up the information from UBW
class SubCostCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parent_cost_code = record.parent.cost_code

    begin
      ubw_sub_project = Ubw::SubProject.find(value)

      if ubw_sub_project.cost_code != parent_cost_code
        record.errors[attribute] << I18n.t("errors.sub_cost_code_parent_mismatch") % [parent_cost_code]
      elsif ubw_sub_project.is_active? == false
        record.errors[attribute] << I18n.t("errors.sub_project_inactive")
      end
    rescue Ubw::Errors::NotFound
      record.errors[attribute] << I18n.t("errors.sub_cost_code_not_found")
    end
  end
end