class Mortgage
  attr_reader :beginning_principal
  attr_accessor :payments_made
  attr_accessor :interest
  attr_accessor :payment
  attr_accessor :remaining_principal
  attr_accessor :total_interest_base
  attr_accessor :years_before_first_adjustment
  attr_accessor :max_rate_adjustment_period
  attr_accessor :max_rate_adjustment_term
  attr_accessor :yearly_interest_rate

  def initialize(initial_interest_rate, principal, term_in_years, max_rate_adjustment_period, max_rate_adjustment_term, years_before_first_adjustment, years_between_adjustments)
    @initial_yearly_interest_rate = interest_rate
    @yearly_interest_rate = interest_rate
    @beginning_principal = principal
    @remaining_principal = principal
    @term_in_years = term_in_years
    @remaining_term_in_months = term_in_years * 12
    @max_rate_adjustment_period = max_rate_adjustment_period
    @max_rate_adjustment_term = max_rate_adjustment_term
    @years_before_first_adjustment = years_before_first_adjustment
    @years_between_adjustments = years_between_adjustments
    @interest_paid = 0.0
    @payments_made = 0
    @payments = []
  end

  def interest_payment
    (@remaining_principal * monthly_interest_rate)
  end

  def principal_payment(payment)
    payment - interest_payment
  end

  def monthly_interest_rate
    @yearly_interest_rate / 12
  end

  def make_payment(payment)
    @interest_paid += interest_payment
    @remaining_principal -= principal_payment(payment)
    @payments_made += 1
    @payments << payment
  end

  def same_payment_outcome(payment)
    adjustment = @years_before_first_adjustment * 12
    while @remaining_principal > 0
      current_payment = determine_payment(@yearly_interest_rate, @remaining_term_in_months, @beginning_principal)
      current_payment = payment unless current_payment > payment
      adjustment.times do
        return if @remaining_principal >= 0
        make_payment(current_payment)
      end
      rate_holder = generate_rate_adjustment(@yearly_interest_rate, @years_between_adjustments)
      rate_holder > @max_rate_adjustment_period ? @yearly_interest_rate += @max_rate_adjustment_period : @yearly_interest_rate += rate_holder
      @yearly_interest_rate >= @initial_yearly_interest_rate + @max_rate_adjustment_term ? @yearly_interest_rate = @initial_yearly_interest_rate + @max_rate_adjustment_term : @yearly_interest_rate = rate
      @remaining_term_in_months -= adjustment
      adjustment = @years_between_adjustments * 12
    end
  end

  def determine_payment(yearly_interest_rate, remaining_term_in_months, remaining_principal)
    ((yearly_interest_rate/(12*100))*(remaining_principal) / (1 - (1 + (yearly_interest_rate/(12*100)))**(-remaining_term_in_months))).round(2) # annuity equation
  end


  def determine_area(rate)
    height_of_curve = 13.793
    if rate < 4
      area_below_rate = ((rate - 2.5)*height_of_curve)/2
    elsif rate > 4 && rate < 6
      area_below_rate = ((2.5*height_of_curve)/2) + (rate - 4)*height_of_curve
    else
      area_below_rate = 100 - ((15-rate) * height_of_curve)/2
    end
    area_below_rate
  end

  def generate_basis_points(rate)
    basis_points = rand(0..100) - determine_area(rate)
    basis_points.round.round(3)
  end

  def generate_rate_adjustment(rate, term)
    rate_adjustment = (generate_basis_points(rate) * term)/100
    rate_adjustment
  end
end



def generate_payments(mortgage)
  payments = []
  rate = mortgage[:initial_rate]
  term_in_months = mortgage[:term]*12
  principal = mortgage[:loan_amount]
  adjustment = mortgage[:years_before_first_adjustment]*12
  current_payment = determine_payment(rate, term_in_months, principal)
  adjustment.times { payments << current_payment }
  principal = (principal * (1 + rate/(12*100))**adjustment) - current_payment * ((((1+rate/(12*100))**adjustment)-1)/(rate/(12*100)))
  rate_holder = generate_rate_adjustment(rate, mortgage[:years_before_first_adjustment])
  rate_holder > mortgage[:max_rate_adjustment_period] ? rate += mortgage[:max_rate_adjustment_period] : rate += rate_holder
  term_in_months = term_in_months - adjustment
  adjustment = mortgage[:years_between_adjustments]*12
  while term_in_months > 0
    rate >= mortgage[:initial_rate]+mortgage[:max_rate_adjustment_term] ? rate = mortgage[:initial_rate]+mortgage[:max_rate_adjustment_term] : rate = rate
    current_payment = determine_payment(rate, term_in_months, principal)
    adjustment.times { payments << current_payment }
    principal = (principal * (1 + rate/(12*100))**adjustment) - current_payment * ((((1+rate/(12*100))**adjustment)-1)/(rate/(12*100)))
    puts "principal #{principal.round(2)}"
    puts "rate #{rate.round(2)}"
    rate_holder = generate_rate_adjustment(rate, mortgage[:years_between_adjustments])
    rate_holder > mortgage[:max_rate_adjustment_period] ? rate += mortgage[:max_rate_adjustment_period] : rate += rate_holder
    term_in_months = term_in_months - adjustment
  end
  mortgage[:payments] = payments
  discount_payments(mortgage)
end

def set_payments_equal(mortgage, competing_payment)
  mortgage_new = Mortgage.new(mortgage[:initial_rate], mortgage[:loan_amount],mortgage[:term],mortgage[:max_rate_adjustment_period],mortgage[:years_before_first_adjustment])
  mortgage[:years_before_first_adjustment].times do
    current_payment = determine_payment(rate, term_in_months, principal)
    current_payment < competing_payment ? current_payment = competing_payment : current_payment = current_payment
    make_payment(current_payment)
    return if mortgage_new.remaining_principal <= 0
    principal = (principal * (1 + rate/(12*100))**adjustment) - current_payment * ((((1+rate/(12*100))**adjustment)-1)/(rate/(12*100)))
    puts "principal #{principal.round(2)}"
    rate += (mortgage[:max_rate_adjustment_period]/2)
    term_in_months = term_in_months - adjustment
  end
end

def discount_payments(mortgage)
  yearly_discount_rate = 1.5  #inflation assumed to be 1.5%
  monthly_discount_rate = yearly_discount_rate / 12
  sum_discounted_payments = 0.0
  mortgage[:payments].each_with_index do |payment, index|
    sum_discounted_payments = sum_discounted_payments + payment/((1 + monthly_discount_rate/100)**index)
  end
  mortgage[:PV_payments] = sum_discounted_payments
end

def determine_payment(yearly_interest_rate, remaining_term_in_months, remaining_principal)
  payment = ((yearly_interest_rate/(12*100))*(remaining_principal) / (1 - (1 + (yearly_interest_rate/(12*100)))**(-remaining_term_in_months))).round(2) # annuity equation
  payment
end

def determine_area(rate)
  height_of_curve = 13.793
  puts "rate at determine_area entrance #{rate}"
  if rate < 4
    area_below_rate = ((rate - 2.5)*height_of_curve)/2
  elsif rate > 4 && rate < 6
    area_below_rate = ((2.5*height_of_curve)/2) + (rate - 4)*height_of_curve
  else
    area_below_rate = 100 - ((15-rate) * height_of_curve)/2
  end
  puts "area_below_rate #{area_below_rate}"
  area_below_rate

end

def generate_basis_points(rate)
  basis_points = rand(0..100) - determine_area(rate)
  puts "basis_points #{basis_points}"
  basis_points.round.round(3)
end

def generate_rate_adjustment(rate, term)
  rate_adjustment = (generate_basis_points(rate) * term)/100
  rate_adjustment
end