require 'optparse'
unless require './github_crawler.rb'
  puts 'Please put crawler.rb in the same directory'
end

options = {
  github_uri: ARGV.first,
  output: './output.xls'
}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby main.rb URIFILE [options]"

  opts.on("-oOUTPUT", "--output=OUTPUT", "Specify output result path (default is ./output.xlsx)") do |o|
    opts[:output] = o
  end

  opts.on("-n", "--no-print", "Don't print processing message") do |n|
    options[:no_print] = !n
  end
end.parse!

if options[:github_uri]
  # number of developers
  # number of bug reports
  # product size
  # number of downloads
  # project rank
  uri_list = File.read(options[:github_uri]).split("\n")
  crawler = Crawler.new(uri_list)
  crawler.crawl(options[:no_print])
  crawler.print_out(options[:output])
else
  puts "Enter github link, use -h to see detail"
end
