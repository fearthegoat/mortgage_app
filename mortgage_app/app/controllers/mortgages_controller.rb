class MortgagesController < ApplicationController

  def index
  end

  def create
    @mortgages = []
    @fixed_rate_payments = []
    params[:mortgage][:rate].each_with_index do |rate, index|
      mortgage_new = Hash.new(0)
      mortgage_new[:loan_amount] = params[:mortgage][:loan].to_d
      mortgage_new[:initial_rate] = rate.to_d
      mortgage_new[:term] = params[:mortgage][:term][index].to_i
      mortgage_new[:years_before_first_adjustment] = params[:mortgage][:years_before_first_adjustment][index].to_i == 0 ? params[:mortgage][:term][index].to_i : params[:mortgage][:years_before_first_adjustment][index].to_i
      mortgage_new[:adjustable_rate?] = params[:mortgage][:years_before_first_adjustment][index].to_i == 0 ? false : true
      mortgage_new[:max_rate_adjustment_period] = params[:mortgage][:max_rate_adjustment_period][index].to_d
      mortgage_new[:max_rate_adjustment_term] = params[:mortgage][:max_rate_adjustment_term][index].to_d
      mortgage_new[:years_between_adjustments] = params[:mortgage][:years_between_adjustments][index].to_i
      @mortgages << mortgage_new
    end
    @mortgages.each do |mortgage|
      generate_payments(mortgage)
      @fixed_rate_payments << mortgage[:payments][0] unless mortgage[:adjustable_rate?] == true
    end
    @mortgages.each do |mortgage|
      if mortgage[:adjustable_rate?] == true
        mortgage_new = Mortgage.new(mortgage)
        mortgage_new.same_payment_outcome(@fixed_rate_payments.max)
        mortgage[:payments_matched] = mortgage_new.payments
      end
    end
    render "results"
  end

  def results
  end

end

# [ {initial_rate: 2.25, loan_amount: 200000, term: 30, initial_term: 5, reoccurring_term: 1, rate_change: 2, max_rate_change: 5, payments: [1,1,1,2] }]