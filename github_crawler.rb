require 'uri'
require 'net/http'
require 'json'
require 'spreadsheet'

class CrawlData
  @@api_host = 'https://api.github.com'
  def initialize(uri)
    @uri = uri
  end

  def crawl(no_print)
    uri_parsed = parse_uri
    @owner = uri_parsed[:owner]
    @repo = uri_parsed[:repo]
    puts "#{@owner}'s #{@repo} is crawling...." unless no_print

    api_uri = URI(@@api_host + "/repos/#{@owner}/#{@repo}")
    api_req = Net::HTTP.get(api_uri)
    @info = JSON.parse(api_req)

    # number of contributors
    @no_dev = crawling_NoDev(no_print)
    # number of years
    @time = crawling_time()
    # number of issues
    @issue = crawling_issue()
    # number of forks
    @fork = crawling_fork()
    # number of stars
    @star = crawling_star()
    # number of downloads
    #@down = crawling_down()
    # project size
    @size = crawling_size()

    puts "#{@owner}'s #{@repo} crawled successfully" unless no_print
    puts "=======================================================" unless no_print
  end

  def uri
    return @uri
  end

  def no_dev
    return @no_dev
  end

  def time
    return @time
  end

  def issue
    return @issue
  end

  def fork
    return @fork
  end

  def star
    return @star
  end

  def size
    return @size
  end

  private

  def parse_uri
    path = @uri.split('/')
    return {owner: path[0], repo: path[1]}
  end

  def crawling_NoDev(no_print)
    uri = URI(@@api_host + "/repos/#{@owner}/#{@repo}/contributors")
    link_head = Net::HTTP.get_response(uri)['link']
    num = 0
    unless link_head.nil?
      page = link_head.split('page=')[-1].split('>')[0].to_i
      uri.query = "page=#{page}"
      num = 30*(page-1)
    end
    request = Net::HTTP.get(uri)
    contributors = JSON.parse(request)
    num += contributors.count
    puts "Number of Contributors crawled" unless no_print
    return num
  end

  def crawling_time()
    time = @info["created_at"]
    return time
  end

  def crawling_issue()
    issue = @info["open_issues_count"]
    return issue
  end

  def crawling_fork()
    forks = @info["forks_count"]
    return forks
  end

  def crawling_star()
    star = @info["stargazers_count"]
    return star
  end

  def crawling_size()
    size = @info["size"]
    return size
  end
end

class Crawler
  def initialize(uris)
    @uri_list = uris
    @data = []
  end

  def crawl(no_print)
    puts @uri_list
    @uri_list.each do |uri|
      cd = CrawlData.new(uri)
      cd.crawl(no_print)
      @data << cd
    end
  end

  def print_out(path)
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(name: 'data')
    sheet1.row(0).concat %w{URI NumberOfContributors NumberOfYears NumberOfIssues NumberOfForks NumberOfStars Size}
    i = 1
    @data.each do |d|
      sheet1.row(i).push d.uri, d.no_dev, d.time, d.issue, d.fork, d.star, d.size
      i += 1
    end

    book.write path
  end
end
