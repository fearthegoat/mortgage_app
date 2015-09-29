class MortgagesController < ApplicationController

  def index
  end

  def create
    @mortgages = []
    @interest_rates = []
    @fixed_rate_payments = []
    random_seed = Random.new_seed
    # @max_term = params[:mortgage][:term].max
    params[:mortgage][:rate].each_with_index do |rate, index|
      mortgage_new = Hash.new(0)
      mortgage_new[:loan_amount] = params[:mortgage][:loan].to_d
      mortgage_new[:random_seed] = random_seed
      mortgage_new[:initial_rate] = rate.to_d
      mortgage_new[:term] = params[:mortgage][:term][index].to_i
      mortgage_new[:years_before_first_adjustment] = params[:mortgage][:years_before_first_adjustment][index].to_i == 0 ? params[:mortgage][:term][index].to_i : params[:mortgage][:years_before_first_adjustment][index].to_i
      mortgage_new[:adjustable_rate?] = params[:mortgage][:years_before_first_adjustment][index].to_i == 0 ? false : true
      mortgage_new[:max_rate_adjustment_period] = params[:mortgage][:max_rate_adjustment_period][index].to_d
      mortgage_new[:max_rate_adjustment_term] = params[:mortgage][:max_rate_adjustment_term][index].to_d
      mortgage_new[:years_between_adjustments] = params[:mortgage][:years_between_adjustments][index].to_i
      @mortgages << mortgage_new
    end
    @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == false }.each do |mortgage|
      generate_payments(mortgage)
      @fixed_rate_payments << mortgage[:payments][0]
    end
    @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == true }.each do |mortgage|
      mortgage_new = Mortgage.new(mortgage)
      mortgage_new.generate_normal_payments
      mortgage[:payments] = mortgage_new.payments_normal
      mortgage[:PV_payments] = mortgage_new.PV_payments_normal
      if @fixed_rate_payments.size > 0
        mortgage_new.same_payment_outcome(@fixed_rate_payments.max)
        mortgage[:PV_payments_matched] = mortgage_new.PV_payments_matched
        mortgage[:payments_matched] = mortgage_new.payments_matched
      end
    end
    render "results"
  end

  def results
  end

end
