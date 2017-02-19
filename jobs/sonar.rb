require 'net/http'
require 'json'

server = "http://sonar.r7.jawg.io"
key = "io.jawg:jawg-stats-api"
metrics = %w{files,lines,overall_coverage,open_issues}.join(',')
id = "sonar"

#http://sonar.r7.jawg.io/api/resources?resource=io.jawg:jawg-stats-api&metrics=Coverage&format=json
#http://sonar.r7.jawg.io/api/measures/component?componentKey=io.jawg:jawg-stats-api&metricKeys=overall_coverage&format=json

sonar_metrics = ['Number of files', 'Number of lines', 'Code coverage', 'Issues']

SCHEDULER.every '1m', :first_in => 0 do |job|
  uri = URI("#{server}/api/measures/component?componentKey=#{key}&metricKeys=#{metrics}&format=json")
	res = Net::HTTP.get(uri)
  measures = JSON[res]['component']['measures']
  sonar_metrics_measues = []

  measures.each do |child|
    metric = child['metric']
    value = child['value']
    if (metric == 'overall_coverage')
      sonar_metrics_measues << { label: child['metric'], value: child['value'] + '%'}
    else
      sonar_metrics_measues << { label: child['metric'], value: child['value'] }
    end
  end

	send_event('sonar', {items: sonar_metrics_measues})
end
