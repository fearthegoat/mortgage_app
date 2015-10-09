task rate_fetcher: :environment do
  page = `curl https://www.navyfederal.org/products-services/loans/mortgage/mortgage-rates.php`

  noko_page = Nokogiri::HTML(page)

  term = 30

  rate = noko_page.css('tr:contains("30 Yr Conforming") td:eq(3)').text
  rate_float = rate.to_f
  puts "#{rate_float}"
  Rate.create(initial_rate: rate_float, term: term)

end