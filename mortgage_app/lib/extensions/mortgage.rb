class Mortgage

  attr_reader :beginning_principal
  attr_accessor :payments_made
  attr_accessor :interest
  attr_accessor :payment
  attr_accessor :remaining_principal
  attr_accessor :total_interest_base

  def initialize(interest_rate, principal, term_in_years)
    @yearly_interest_rate = interest_rate/100
    @beginning_principal = principal
    @remaining_principal = principal
    @payment = ((@yearly_interest_rate/12)*(@beginning_principal) / (1 - (1 + (@yearly_interest_rate/12))**(-term_in_years*12))).round(2) # annuity equation
    @total_interest_base = @payment * term_in_years * 12 - @beginning_principal
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

