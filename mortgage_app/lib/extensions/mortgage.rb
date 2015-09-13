class Mortgage
  attr_reader :beginning_principal
  attr_accessor :payments_made
  attr_accessor :interest
  attr_accessor :payment
  attr_accessor :remaining_principal
  attr_accessor :total_interest_base
  attr_accessor :years_before_adjustment
  attr_accessor :max_rate_adjustment

  def initialize(interest_rate, principal, term_in_years, max_rate_adjustment, years_before_adjustment)
    @initial_yearly_interest_rate = interest_rate/100
    @beginning_principal = principal
    @remaining_principal = principal
    @term_in_years = term_in_years
    @max_rate_adjustment = max_rate_adjustment
    @years_before_adjustment = years_before_adjustment
    @interest_paid = 0.0
    @payments_made = 0
  end

  def interest_payment
    (@remaining_principal * monthly_interest_rate).round(2)
  end

  def principal_payment(payment = @payment)
    payment - interest_payment
  end

  def monthly_interest_rate
    @yearly_interest_rate / 12
  end

  def make_payment
    @interest_paid += interest_payment
    @remaining_principal -= principal_payment
    @payments_made += 1
  end
end

discount_rate = 1.5

def generate_payments(mortgage)
  payments = []
  rate = mortgage[:initial_rate]
  term_in_months = mortgage[:term]*12
  principal = mortgage[:loan_amount]
  adjustment = mortgage[:years_before_adjustment]*12
  while term > 0
    current_payment = determine_payment(rate, term_in_months, principal)
    adjustment.times { payments << current_payment }
    principal = (principal * (1 + rate)^adjustment) - current_payment * (((1+rate)^adjustment-1)/rate)
    rate += (mortgage[:max_rate_adjustment]/2)
    term_in_months +- adjustment
  end
  mortgage[:payments] = payments
end

def discount_payments(mortgage)

end

def determine_payment(yearly_interest_rate, remaining_term_in_months, remaining_principal)
  payment = ((yearly_interest_rate/12)*(remaining_principal) / (1 - (1 + (yearly_interest_rate/12))**(-remaining_term_in_months))).round(2) # annuity equation
  payment
end

