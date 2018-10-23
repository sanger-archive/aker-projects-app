require 'billing_facade_client'

module MockBilling

  def valid_project_cost_code
    return @valid_project_cost_code if @valid_project_cost_code
    @valid_project_cost_code = 'S1234'
    allow(BillingFacadeClient).to receive(:validate_project_cost_code?).with(@valid_project_cost_code).and_return(@valid_project_cost_code)
    allow(BillingFacadeClient).to receive(:validate_subproject_cost_code?).with(@valid_project_cost_code).and_return(false)
    allow(BillingFacadeClient).to receive(:get_sub_cost_codes).with(@valid_project_cost_code).and_return([@valid_subproject_cost_code])
    @valid_project_cost_code = mock_cost_code('S1234')
  end

  def another_valid_project_cost_code
    return @another_valid_project_cost_code if @another_valid_project_cost_code
    @another_valid_project_cost_code = 'S0000'
    allow(BillingFacadeClient).to receive(:validate_project_cost_code?).with(@another_valid_project_cost_code).and_return(@another_valid_project_cost_code)
    allow(BillingFacadeClient).to receive(:validate_subproject_cost_code?).with(@another_valid_project_cost_code).and_return(false)
    @another_valid_project_cost_code = mock_cost_code('S0000')
  end

  def valid_subproject_cost_code
    return @valid_subproject_cost_code if @valid_subproject_cost_code
    @valid_subproject_cost_code = 'S1234-560'
    allow(BillingFacadeClient).to receive(:validate_subproject_cost_code?).with(@valid_subproject_cost_code).and_return(@valid_subproject_cost_code)
    allow(BillingFacadeClient).to receive(:validate_project_cost_code?).with(@valid_subproject_cost_code).and_return(false)
    allow(BillingFacadeClient).to receive(:get_sub_cost_codes).with(@valid_project_cost_code).and_return([@valid_subproject_cost_code])
    @valid_subproject_cost_code = mock_cost_code('S1234-560')
  end

  def mock_cost_code(cost_code)
    allow(BillingFacadeClient).to receive(:validate_cost_code?).with(cost_code).and_return(cost_code)
    cost_code
  end

  def mock_subproject_cost_code(cost_code)
    allow(BillingFacadeClient).to receive(:validate_cost_code?).with(cost_code).and_return(cost_code)
    allow(BillingFacadeClient).to receive(:validate_subproject_cost_code?).with(cost_code).and_return(cost_code)
    allow(BillingFacadeClient).to receive(:get_sub_cost_codes).with(@valid_project_cost_code).and_return([cost_code])
    cost_code
  end


end
