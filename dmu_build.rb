require 'uri'
require 'net/http'
require 'json'

class RepoFilter
  @@min_issue_count = 50
  def initialize(data)
    values = []
    data.each do |d|
      tmp = d.split('/')
      values << {owner: tmp[0], repo: tmp[1]}
    end
    @data = values
  end

  def filter(output)
    results = []
    @data.each do |d|
      uri = URI("https://api.github.com/repos/#{d[:owner]}/#{d[:repo]}")
      req = Net::HTTP.get(uri)
      repo = JSON.parse(req)
      puts "#{uri} | license: #{repo["license"]} | issue: #{repo["open_issues_count"]} | private: #{repo["private"]}"
      next if repo["license"].nil?
      if repo["open_issues_count"] > @@min_issue_count and !repo["private"]
        puts "pass"
        results << d
      end
    end

    File.open(output, 'w') do |f|
      results.each do |r|
        f.puts "#{r[:owner]}/#{r[:repo]}"
      end
    end
  end

end
