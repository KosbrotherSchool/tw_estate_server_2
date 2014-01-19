class ParseWorker
  include Sidekiq::Worker
  sidekiq_options queue: "estate"

  def perform(raw_page_id)
    raw_page = RawPage.find(raw_page_id)
	parser = RawDataParser.new
	parser.parse_raw_data raw_page_id
  end
end