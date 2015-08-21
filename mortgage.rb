class Mortgage

  attr_accessor :principle
  attr_accessor :interest
  attr_accessor :payment

  def initialize(interest_rate, principle)
    @interest = interest_rate
    @principle = principle
    @payment = 2000
  end

  def interest_payment
    @principle * monthly_interest
  end

  def principle_payment
    @payment - interest_payment
  end

  def monthly_interest
    @interest / 12
  end
end
