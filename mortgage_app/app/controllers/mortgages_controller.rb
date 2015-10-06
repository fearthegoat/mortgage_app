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
      @fixed_rate_payments << mortgage[:payments_normal][0]
    end
    @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == true }.each do |mortgage|
      mortgage_new = Mortgage.new(mortgage)
      mortgage_new.generate_normal_payments
      mortgage[:payments] = mortgage_new.payments_normal
      mortgage[:PV_payments] = mortgage_new.PV_payments_normal
      mortgage[:interest_normal] = mortgage_new.interest_normal
      mortgage_new.worst_case_scenario
      mortgage[:PV_payments_worst] = mortgage_new.PV_payments_worst
      mortgage[:payments_worst] = mortgage_new.payments_worst
      if @fixed_rate_payments.size > 0
        mortgage_new.same_payment_outcome(@fixed_rate_payments.max)
        mortgage[:PV_payments_matched] = mortgage_new.PV_payments_matched
        mortgage[:payments_matched] = mortgage_new.payments_matched
        mortgage[:interest_matched] = mortgage_new.interest_matched
      end
    end
    if @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == true }.size > 0 && @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == false }.size > 0
      determine_sale_date
    end
    render "results"
  end

  def results
  end

  def determine_sale_date
    fixed_rate_mortgage = @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == false && mortgage[:payments_normal].first == @fixed_rate_payments.min }.first
    adjustable_rate_mortgage = @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == true}.first
    sale = CSP.new
    sale.var(:term, 5..360)
    sale.constrain(:term) { |n| ((fixed_rate_mortgage[:interest_normal][0..(n)].inject{|sum,x| sum + x }) - (adjustable_rate_mortgage[:interest_normal][0..(n)].inject{|sum,x| sum + x })) > 0 && ((fixed_rate_mortgage[:interest_normal][0..(n+1)].inject{|sum,x| sum + x }) - (adjustable_rate_mortgage[:interest_normal][0..(n+1)].inject{|sum,x| sum + x })) < 0}
    @sale_date = sale.solve[:term]
  end
end
