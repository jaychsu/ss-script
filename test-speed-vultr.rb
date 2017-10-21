# gem install down rails
# ruby test-speed-vultr.rb | column -t -s "|"

require 'open-uri'
require 'nokogiri'
require 'down'
require 'benchmark'
require 'rails/all'

include ActionView::Helpers::NumberHelper

def continue?(chunk, started_at, downloaded_size)
  return false if chunk.eof?
  return false if (Time.now - started_at) >= 30
  return false if downloaded_size > (10 * 1024 * 1024)
  return true
end

class Result
  class Round
    attr_reader :duration_first_4k, :duration, :speed

    def initialize(started_at, first_4k, downloaded_size)
      @started_at, @first_4k, @downloaded_size = started_at, first_4k, downloaded_size
      @duration_first_4k = @first_4k - @started_at
      @duration = Time.now - @started_at
      @speed = @downloaded_size.to_f / @duration
    end
  end

  def initialize(server, test_url)
    @server, @test_url = server, test_url
    @rounds = []
  end

  def add(started_at, first_4k, downloaded_size)
    @rounds.append(Round.new(started_at, first_4k, downloaded_size))
  end

  def to_line
    if (@rounds == 0)
      [@server, @test_url, 0] + %w[NA] * 4
    else
      total_4k, total_duration, total_speed = *(@rounds.reduce([0, 0, 0]) {|a, b| a[0] += b.duration_first_4k; a[1] += b.duration; a[2] += b.speed; a })
      [@server, @test_url, @rounds.size,
       number_with_precision(total_duration) + "s",
       number_with_precision(total_4k / @rounds.size) + "s",
       number_with_precision(total_duration / @rounds.size) + "s",
       number_to_human_size(total_speed / @rounds.size) + "/s"]
    end.join("|")
  end
end

LOGGER = Logger.new(STDERR)
test_count = ARGV[0].to_i
test_count = 3 if test_count < 1

unless ARGV[1] == "debug"
  LOGGER.level = :info
end

LOGGER.info("Start tests...Test Rounds: #{test_count}\tLogger LEVEL: #{LOGGER.level}")

LOGGER.info("fetching list...")
html = open("https://www.vultr.com/faq/#downloadspeedtests").read
doc = Nokogiri.HTML html
trs = doc.css("#speedtest_v4 tr").to_a

results = []
test_count.times do |t|
  trs.each_with_index do |tr, i|
    tds = tr.css("td")
    server = tds[0].text.strip
    test_link = tds[2].css("a").first
    test_url = test_link.attr("href").strip
    result = (results[i] ||= Result.new(server, test_url))
    LOGGER.info("testing #{server}...#{t}")

    started_at = Time.now
    first_4k = 0
    downloaded_size = 0
    chunk = nil
    begin
      chunk = Down.open(test_url)
      data = chunk.read(1024*4)
      downloaded_size += data.size
      first_4k = Time.now
      while (continue?(chunk, started_at, downloaded_size))
        LOGGER.debug(">>>>>>>>>> #{server} #{downloaded_size}")
        data = chunk.read(1024*64)
        downloaded_size += data.size
      end
      result.add(started_at, first_4k, downloaded_size)
      LOGGER.info("#{test_url} done...#{downloaded_size}")
    rescue Down::TimeoutError => e
      LOGGER.error("timeout! #{server}")
    ensure
      chunk.close unless chunk.nil?
    end
  end
end
puts results.map(&:to_line)
