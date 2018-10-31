Rails.application.config.after_initialize do
  Ubw::Client.site = Rails.application.config.ubw_service_url

  # If not enabled mock the behaviour. Useful for development.
  if !Rails.application.config.ubw[:enabled]
    require 'ostruct'

    Ubw::SubProject = Class.new do

      # Always return an active SubProject
      def self.find(sub_cost_code)
        OpenStruct.new(sub_cost_code: sub_cost_code, cost_code: sub_cost_code.split('-').first, is_active?: true, status: 'N')
      end

      # params will be { cost_code: cost_code }
      # Always return a ResultSet of 3 active SubProjects
      def self.where(params)
        cost_code = params.fetch(:cost_code)

        items = (101..103).map do | sub_part |
          OpenStruct.new(sub_cost_code: "#{cost_code}-#{sub_part}", cost_code: cost_code, is_active?: true, status: 'N')
        end

        OpenStruct.new(items: items, result_count: items.size)
      end

    end
  end
end
