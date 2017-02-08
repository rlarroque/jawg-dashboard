require 'net/http'
require 'json'

server = "http://sonar.r7.jawg.io"
key = "io.jawg:jawg-stats-api"
metrics = %w{overall_coverage}.join(',')
id = "sonar"

#http://sonar.r7.jawg.io/api/resources?resource=io.jawg:jawg-stats-api&metrics=Coverage&format=json
#http://sonar.r7.jawg.io/api/measures/component?componentKey=io.jawg:jawg-stats-api&metricKeys=overall_coverage&format=json

SCHEDULER.every '10s', :first_in => 0 do |job|
  uri = URI("#{server}/api/measures/component?componentKey=#{key}&metricKeys=#{metrics}&format=json")
	res = Net::HTTP.get(uri)
  j = JSON[res]['component']['measures']

puts j[0]['value']
	send_event('sonar', current: j[0]['value'])
end
