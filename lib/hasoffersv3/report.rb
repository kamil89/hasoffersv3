module HasOffersV3
  class Report < Base
    Target = 'Report'

    class << self
      def getConversions(params = {}, &block)
        get_request(Target, 'getConversions', params, &block)
      end

      def getModSummaryLogs(params = {}, &block)
        get_request(Target, 'getModSummaryLogs', params, &block)
      end
    end
  end
end