$(document).ready(function() {
  var add_fixed_rate, add_adjustable_rate, max_fields, wrapper, x;
  max_fields = 4;
  wrapper = $('#form_start');
  add_fixed_rate = $('#add_fixed_rate');
  add_adjustable_rate = $('#add_adjustable_rate');
  x = 1;

  $(add_fixed_rate).click(function(e) {
    e.preventDefault();
    if (x < max_fields) {
      x++;
      $(wrapper).append('<div class="row"><div class="input-field col s12 m4"><input id="fixed_rate" class="validate" placeholder="i.e: 3.75" step=".125" min="1" max="15" type="number" name="mortgage[rate][]"><label for="fixed_rate" class="active">Interest Rate (APR)</label></div><div class="input-field col s12 m4 offset-m1"><input id="fixed_term" class="validate" placeholder="i.e.: 30" step="5" min="5" max="30" type="number" name="mortgage[term][]"><label for="fixed_term" class="active">Term (years)</label></div><input id="years_before_adjustment" type="hidden" value ="0" name="mortgage[years_before_adjustment][]"><input id="max_rate_adjustment" type="hidden" value ="0" name="mortgage[max_rate_adjustment][]"></div>');
    listen_to_form();
    }
    else {
      return alert("Only six patrons can be signed up on a single booking.  If your party is larger, either contact us or sign-up on separate bookings.  Thank you.")
    };
  });
});