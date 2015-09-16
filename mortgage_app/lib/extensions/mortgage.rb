class Mortgage
  attr_reader :beginning_principal
  attr_accessor :payments_made
  attr_accessor :interest
  attr_accessor :payment
  attr_accessor :remaining_principal
  attr_accessor :total_interest_base
  attr_accessor :years_before_adjustment
  attr_accessor :max_rate_adjustment_period

  def initialize(interest_rate, principal, term_in_years, max_rate_adjustment_period, years_before_adjustment)
    @initial_yearly_interest_rate = interest_rate/100
    @beginning_principal = principal
    @remaining_principal = principal
    @term_in_years = term_in_years
    @max_rate_adjustment_period = max_rate_adjustment_period
    @years_before_adjustment = years_before_adjustment
    @interest_paid = 0.0
    @payments_made = 0
    @payments = []
  end

  def interest_payment
    (@remaining_principal * monthly_interest_rate).round(2)
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
  end
end



def generate_payments(mortgage)
  payments = []
  rate = mortgage[:initial_rate]
  term_in_months = mortgage[:term]*12
  principal = mortgage[:loan_amount]
  adjustment = mortgage[:years_before_adjustment_period]*12
  while term_in_months > 0
    current_payment = determine_payment(rate, term_in_months, principal)
    adjustment.times { payments << current_payment }
    principal = (principal * (1 + rate/(12*100))**adjustment) - current_payment * ((((1+rate/(12*100))**adjustment)-1)/(rate/(12*100)))
    puts "principal #{principal.round(2)}"
    rate += (mortgage[:max_rate_adjustment_period]/2)
    term_in_months = term_in_months - adjustment
  end
  mortgage[:payments] = payments
  discount_payments(mortgage)
end

def set_payments_equal(mortgage, competing_payment)
  mortgage_new = Mortgage.new(mortgage[:initial_rate], mortgage[:loan_amount],mortgage[:term],mortgage[:max_rate_adjustment_period],mortgage[:years_before_adjustment])
  payments = []
  mortgage[:years_before_adjustment].times do
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

def make_payment
  @interest_paid += interest_payment
  @remaining_principal -= principal_payment
  @payments_made += 1
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

