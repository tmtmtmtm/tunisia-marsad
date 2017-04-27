#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.css('a.depute').map do |a|
      fragment a => MemberLink
    end
  end
end

terms = {
  '2011' => 'http://majles.marsad.tn/fr/assemblee',
  '2014' => 'http://majles.marsad.tn/2014/fr/assemblee',
}

terms.each do |term, url|
  page = MembersPage.new(response: Scraped::Request.new(url: url).response)
  page.members.each do |mem|
    data = mem.to_h.merge(term: term)
    # puts data
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end
