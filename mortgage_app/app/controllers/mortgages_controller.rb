class MortgagesController < ApplicationController

  def index
  end

  def create
    @mortgages = []
    @interest_rates = []
    @fixed_rate_payments = []
    @compared_mortgages = []
    random_seed = Random.new_seed
    add_database_mortgage_to_params
    generate_taxes
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
      mortgage[:payments_normal] = mortgage_new.payments_normal
      mortgage[:PV_payments] = mortgage_new.PV_payments_normal
      mortgage[:interest_normal] = mortgage_new.interest_normal
      mortgage[:PV_interest_tax] = mortgage_new.PV_interest_tax
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
    generate_charts
    render "results"
  end

  def results
  end

  def generate_charts
    @chart_interest_payment = []
    @chart_cumulative_interest = []
    @chart_payment = []
    @mortgages.each do |mortgage|
      mortgage[:cumulative_interest] = mortgage[:interest_normal].cumulative_sum
      mortgage_hash = Hash.new
      mortgage_data_hash = Hash[((0..mortgage[:interest_normal].size).to_a).zip(mortgage[:interest_normal])]
      mortgage_hash.merge!(data: mortgage_data_hash)
      mortgage_hash.merge!(name: mortgage[:adjustable_rate?] ? "#{mortgage[:years_before_first_adjustment]}/#{mortgage[:years_between_adjustments]} ARM" : "#{mortgage[:initial_rate]}% Fixed Rate")
      @chart_interest_payment << mortgage_hash
      mortgage_hash = Hash.new
      mortgage_data_hash = Hash[((0..mortgage[:cumulative_interest].size).to_a).zip(mortgage[:cumulative_interest])]
      mortgage_hash.merge!(data: mortgage_data_hash)
      mortgage_hash.merge!(name: mortgage[:adjustable_rate?] ? "#{mortgage[:years_before_first_adjustment]}/#{mortgage[:years_between_adjustments]} ARM" : "#{mortgage[:initial_rate]}% Fixed Rate")
      @chart_cumulative_interest << mortgage_hash
      mortgage_hash = Hash.new
      mortgage_data_hash = Hash[((0..mortgage[:payments_normal].size).to_a).zip(mortgage[:payments_normal])]
      mortgage_hash.merge!(data: mortgage_data_hash)
      mortgage_hash.merge!(name: mortgage[:adjustable_rate?] ? "#{mortgage[:years_before_first_adjustment]}/#{mortgage[:years_between_adjustments]} ARM" : "#{mortgage[:initial_rate]}% Fixed Rate")
      @chart_payment << mortgage_hash
    end
  end

  def determine_sale_date
    fixed_rate_mortgage = @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == false && mortgage[:payments_normal].first == @fixed_rate_payments.min }.first
    adjustable_rate_mortgage = @mortgages.select { |mortgage| mortgage[:adjustable_rate?] == true}.first
    @compared_mortgages << fixed_rate_mortgage
    @compared_mortgages << adjustable_rate_mortgage
    sale = CSP.new
    sale.var(:term, 5..360)
    sale.constrain(:term) { |n| ((fixed_rate_mortgage[:interest_normal][0..(n)].inject{|sum,x| sum + x }) - (adjustable_rate_mortgage[:interest_normal][0..(n)].inject{|sum,x| sum + x })) > 0 && ((fixed_rate_mortgage[:interest_normal][0..(n+1)].inject{|sum,x| sum + x }) - (adjustable_rate_mortgage[:interest_normal][0..(n+1)].inject{|sum,x| sum + x })) < 0}
    @sale_date = sale.solve[:term]
  end

  def add_database_mortgage_to_params
    database = Rate.order(created_at: :desc).first
    params[:mortgage][:rate] << database.initial_rate
    params[:mortgage][:term] << database.term
    params[:mortgage][:years_before_first_adjustment] << database.years_before_first_adjustment
    params[:mortgage][:max_rate_adjustment_period] << database.max_rate_adjustment_period
    params[:mortgage][:max_rate_adjustment_term] << database.max_rate_adjustment_term
    params[:mortgage][:years_between_adjustments] << database.years_between_adjustments
  end

  def generate_taxes
    @tax_rate = (1/5000000.0) * params[:mortgage][:loan].to_f + 0.14  # linear tax rate, y = mx + b
    @tax_rate = 0.33 if @tax_rate > 0.33
    @n = 0
    $tax_rate_array = []
    generate_tax_array
  end

  def generate_tax_array
    return if @n == 30
    max_tax_rate = 0.33 # 33% marginal tax rate
    12.times {$tax_rate_array << @tax_rate} # yearly change in tax rate vice monthly
    @tax_rate = max_tax_rate / (1 + (((max_tax_rate/@tax_rate)-1)* Math.exp(-0.004*@n))) # equation is an adapted population growth equatino.  0.004 is a constant to achieve a plausible curve
    @n += 1
    generate_tax_array
  end
end

