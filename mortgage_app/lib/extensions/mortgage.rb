class Mortgage
  attr_reader :beginning_principal
  attr_accessor :payments_made, :initial_yearly_interest_rate, :payments, :remaining_principal, :total_interest_base, :years_before_first_adjustment, :max_rate_adjustment_period,:max_rate_adjustment_term, :yearly_interest_rate, :payments_matched, :PV_payments_matched, :PV_payments_normal, :payments_normal, :PV_payments_worst, :payments_worst, :interest_matched, :interest_normal

  def initialize(mortgage)
    @initial_yearly_interest_rate = mortgage[:initial_rate]
    @yearly_interest_rate = mortgage[:initial_rate]
    @beginning_principal = mortgage[:loan_amount]
    @remaining_principal = mortgage[:loan_amount]
    @term_in_years = mortgage[:term]
    @remaining_term_in_months = mortgage[:term] * 12
    @max_rate_adjustment_period = mortgage[:max_rate_adjustment_period]
    @max_rate_adjustment_term = mortgage[:max_rate_adjustment_term]
    @years_before_first_adjustment = mortgage[:years_before_first_adjustment]
    @years_between_adjustments = mortgage[:years_between_adjustments]
    @interest_paid = 0.0
    @payments_made = 0
    @payments = []
    @interest = []
    @basis_points = []
    @payments_matched = []
    @payments_normal = []
    @PV_payments_normal = 0.0
    @PV_payments_matched = 0.0
    @random_generator = Random.new(mortgage[:random_seed])

    if mortgage[:years_before_first_adjustment] <= 3
      @estimated_teaser_discount = 1
    elsif mortgage[:years_before_first_adjustment] > 3 && mortgage[:years_before_first_adjustment] < 10
      @estimated_teaser_discount = 0.75
    elsif mortgage[:years_before_first_adjustment] >= 10 && mortgage[:years_before_first_adjustment] < 15
      @estimated_teaser_discount = 0.50
    else
      @estimated_teaser_discount = 0.25
    end

    number_times_to_calculate = 20
    30.times do  # 30 because the max term in years possible
      calculation_holder = []
      number_times_to_calculate.times do
        calculation_holder << (generate_basis_points(@estimated_teaser_discount + mortgage[:initial_rate]))/100
      end
      summed = calculation_holder.inject {|sum,x| sum + x }
      rate_holder = (summed / number_times_to_calculate).round(5) # finds average
      puts "rate holder #{rate_holder}"
      @basis_points << rate_holder
      @estimated_teaser_discount += rate_holder
    end
    @basis_points[0] = @basis_points[0] + @yearly_interest_rate
  end

  def interest_payment
    ((@remaining_principal * monthly_interest_rate)).round(2)
  end

  def principal_payment(payment)
    payment - interest_payment
  end

  def monthly_interest_rate
    @yearly_interest_rate / (12 * 100)
  end

  def make_payment(payment)
    @interest_paid += interest_payment
    @interest << interest_payment
    @remaining_principal = (@remaining_principal - principal_payment(payment)).round(3)
    @payments_made += 1
    @payments << payment
  end

  def generate_normal_payments
    adjustment = @years_before_first_adjustment * 12 #3 * 12
    current_year = 0
    while @remaining_term_in_months > 0
      current_payment = determine_payment(@yearly_interest_rate, @remaining_term_in_months, @remaining_principal)
      adjustment.times do
        make_payment(current_payment)
      end
      rate_holder = @basis_points[current_year..(current_year+(adjustment/12)-1)].inject{|sum,x| sum + x }
      rate_holder > @max_rate_adjustment_period ? @yearly_interest_rate += @max_rate_adjustment_period : @yearly_interest_rate += rate_holder
      @yearly_interest_rate = @initial_yearly_interest_rate + @max_rate_adjustment_term if @yearly_interest_rate >= @initial_yearly_interest_rate + @max_rate_adjustment_term
      @remaining_term_in_months -= adjustment
      current_year += adjustment/12
      adjustment = @years_between_adjustments * 12
    end
    @PV_payments_normal = discount_payments(@payments)
    @payments_normal = @payments
    @interest_normal = @interest
    reset_variables
  end

  def same_payment_outcome(payment)
    adjustment = @years_before_first_adjustment * 12 #3 * 12
    current_year = 0
    while @remaining_principal > 1
      current_payment = determine_payment(@yearly_interest_rate, @remaining_term_in_months, @remaining_principal)
      current_payment = current_payment.round(2)
      current_payment = payment unless current_payment > payment
      counter = 0
      while @remaining_principal > 1 && counter < adjustment
        make_payment(current_payment)
        counter += 1
      end
      rate_holder = @basis_points[current_year..(current_year+(adjustment/12)-1)].inject{|sum,x| sum + x }
      rate_holder > @max_rate_adjustment_period ? @yearly_interest_rate += @max_rate_adjustment_period : @yearly_interest_rate += rate_holder
      @yearly_interest_rate = @initial_yearly_interest_rate + @max_rate_adjustment_term if @yearly_interest_rate >= @initial_yearly_interest_rate + @max_rate_adjustment_term
      @remaining_term_in_months -= adjustment
      current_year += adjustment/12
      adjustment = @years_between_adjustments * 12
    end
    @PV_payments_matched = discount_payments(@payments)
    @payments_matched = @payments
    @interest_matched = @interest
    reset_variables
  end

  def worst_case_scenario
    adjustment = @years_before_first_adjustment * 12
    while @remaining_term_in_months > 0
      current_payment = determine_payment(@yearly_interest_rate, @remaining_term_in_months, @remaining_principal)
      adjustment.times do
        @payments << current_payment
        puts "current_payment #{current_payment}"
      end
      @remaining_principal = ((@remaining_principal * (1 + @yearly_interest_rate/(12*100))**adjustment) - current_payment * ((((1+@yearly_interest_rate/(12*100))**adjustment)-1)/(@yearly_interest_rate/(12*100)))).round(3)
      puts "remaining principal #{@remaining_principal}"
      @yearly_interest_rate += @max_rate_adjustment_period
      @yearly_interest_rate = @initial_yearly_interest_rate + @max_rate_adjustment_term if @yearly_interest_rate > @initial_yearly_interest_rate + @max_rate_adjustment_term
      @remaining_term_in_months -= adjustment
      puts "remaining term #{@remaining_term_in_months}"
      puts "adjustment #{adjustment}"
      adjustment = @years_between_adjustments * 12
    end
    @PV_payments_worst = discount_payments(@payments)
    @payments_worst = @payments
    reset_variables
  end

  def determine_payment(yearly_interest_rate, remaining_term_in_months, remaining_principal)
    ((yearly_interest_rate/(12*100))*(remaining_principal) / (1 - (1 + (yearly_interest_rate/(12*100)))**(-remaining_term_in_months))).round(2) # annuity equation
  end


  def determine_area(rate)
    height_of_curve = 12.5
    if rate <= 6
      area_below_rate = ((rate - 2.5)*height_of_curve)
    else
      area_below_rate = 100 - ((15-rate) * height_of_curve)/2
    end
    area_below_rate
  end

  def generate_basis_points(rate)
    @random_generator.rand(0..100) - determine_area(rate)
  end

  def discount_payments(payments)
    yearly_discount_rate = 1.5  #inflation assumed to be 1.5%
    monthly_discount_rate = yearly_discount_rate / 12
    sum_discounted_payments = 0.0
    payments.each_with_index do |payment, index|
      sum_discounted_payments = sum_discounted_payments + payment/((1 + monthly_discount_rate/100)**index)
    end
    sum_discounted_payments
  end

  def reset_variables
    @payments = []
    @interest = []
    @remaining_principal = @beginning_principal
    @remaining_term_in_months = @term_in_years * 12
    @yearly_interest_rate = @initial_yearly_interest_rate
  end
end

# for fixed rate mortgages
def generate_payments(mortgage)
  @payments = []
  @interest = []
  @rate = mortgage[:initial_rate]
  term_in_months = mortgage[:term]*12
  @principal = mortgage[:loan_amount]
  @remaining_principal = mortgage[:loan_amount]
  adjustment = mortgage[:years_before_first_adjustment]*12
  current_payment = determine_payment(@rate, term_in_months, @principal)
  adjustment.times { make_payment(current_payment) }
  mortgage[:payments_normal] = @payments
  mortgage[:interest_normal] = @interest
  discount_payments(mortgage)
end

def interest_payment
  (@remaining_principal * (@rate/(12*100))).round(2)
end

def principal_payment(payment)
  payment - interest_payment
end

def make_payment(payment)
  @interest << interest_payment
  @remaining_principal = (@remaining_principal - principal_payment(payment)).round(3)
  @payments << payment
end

def discount_payments(mortgage)
  yearly_discount_rate = 1.5  #inflation assumed to be 1.5%
  monthly_discount_rate = yearly_discount_rate / 12
  sum_discounted_payments = 0.0
  mortgage[:payments_normal].each_with_index do |payment, index|
    sum_discounted_payments = sum_discounted_payments + payment/((1 + monthly_discount_rate/100)**index)
  end
  mortgage[:PV_payments] = sum_discounted_payments
end

def determine_payment(yearly_interest_rate, remaining_term_in_months, remaining_principal)
  payment = ((yearly_interest_rate/(12*100))*(remaining_principal) / (1 - (1 + (yearly_interest_rate/(12*100)))**(-remaining_term_in_months))).round(2) # annuity equation
  payment
end

