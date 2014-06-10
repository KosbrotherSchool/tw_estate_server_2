# encoding: utf-8
class RawDataWorker
  include Sidekiq::Worker
  sidekiq_options queue: "estate"
  
  def perform(town_id)
    mTown = Town.find(town_id)
    crawler = RawDataCrawler.new
    crawler.crawl_town_data(town_id,103,4, 103, 4)
  end

end