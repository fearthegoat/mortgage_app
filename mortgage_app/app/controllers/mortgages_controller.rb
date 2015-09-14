class MortgagesController < ApplicationController

  def index
  end

  def create
    @mortgages = []
    params[:mortgage][:rate].each_with_index do |rate, index|
      mortgage_new = Hash.new(0)
      mortgage_new[:loan_amount] = params[:mortgage][:loan].to_d
      mortgage_new[:initial_rate] = rate.to_d
      mortgage_new[:term] = params[:mortgage][:term][index].to_i
      mortgage_new[:years_before_adjustment] = params[:mortgage][:years_before_adjustment][index].to_i == 0 ? params[:mortgage][:term][index].to_i : params[:mortgage][:years_before_adjustment][index].to_i
      mortgage_new[:max_rate_adjustment] = params[:mortgage][:max_rate_adjustment][index].to_d
      @mortgages << mortgage_new
    end
    @mortgages.each do |mortgage|
      generate_payments(mortgage)
    end
    render "results"
  end

  def results
  end

end


# [ {initial_rate: 2.25, loan_amount: 200000, term: 30, initial_term: 5, reoccurring_term: 1, rate_change: 2, max_rate_change: 5, payments: [1,1,1,2] }]