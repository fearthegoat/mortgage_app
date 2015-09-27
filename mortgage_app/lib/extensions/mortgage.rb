class Mortgage
  attr_reader :beginning_principal
  attr_accessor :payments_made, :initial_yearly_interest_rate, :payments, :remaining_principal, :total_interest_base, :years_before_first_adjustment, :max_rate_adjustment_period,:max_rate_adjustment_term, :yearly_interest_rate

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
    @basis_points = []
    @random_generator = Random.new(@random_seed)

    if mortgage[:years_before_first_adjustment] <= 3
      @estimated_teaser_discount = 1
    elsif mortgage[:years_before_first_adjustment] > 3 && mortgage[:years_before_first_adjustment] < 10
      @estimated_teaser_discount = 0.75
    elsif mortgage[:years_before_first_adjustment] >= 10 && mortgage[:years_before_first_adjustment] < 15
      @estimated_teaser_discount = 0.50
    else
      @estimated_teaser_discount = 0.25
    end

    @max_term.times do
      rate_holder = generate_basis_points(@estimated_teaser_discount + mortgage_new[:initial_rate])
      @basis_points << rate_holder
      @estimated_base_rate += rate_holder
    end
    @basis_points[0] = @basis_points[0] + @estimated_teaser_discount*100

  end

  def interest_payment
    (@remaining_principal * monthly_interest_rate)
  end

  def principal_payment(payment)
    payment - interest_payment
  end

  def monthly_interest_rate
    @yearly_interest_rate / (12 * 100)
  end

  def make_payment(payment)
    @interest_paid += interest_payment
    @remaining_principal -= principal_payment(payment)
    @payments_made += 1
    @payments << payment
  end

  def same_payment_outcome(payment)
    adjustment = @years_before_first_adjustment * 12 #3 * 12
    current_year = 0
    while @remaining_principal > 0
      current_payment = determine_payment(@yearly_interest_rate, @remaining_term_in_months, @remaining_principal)
      current_payment = payment unless current_payment > payment
      adjustment.times do
        return if @remaining_principal <= 0
        make_payment(current_payment)
      end
      rate_holder = @basis_points[current_year..(current_year+(adjustment/12)-1)].inject{|sum,x| sum + x }
      rate_holder/100 > @max_rate_adjustment_period ? @yearly_interest_rate += @max_rate_adjustment_period : @yearly_interest_rate += rate_holder/100
      @yearly_interest_rate >= @initial_yearly_interest_rate + @max_rate_adjustment_term ? @yearly_interest_rate = @initial_yearly_interest_rate + @max_rate_adjustment_term : @yearly_interest_rate = @yearly_interest_rate
      @remaining_term_in_months -= adjustment
      current_year += adjustment/12
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
    @random_generator.rand(0..100) - determine_area(rate)
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