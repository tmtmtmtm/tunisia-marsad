#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def gender_from(text)
  return if text.to_s.empty?
  return 'male' if text == 'Hommes'
  return 'female' if text == 'Femmes'
  raise "Unknown gender: #{text}"
end

def scrape_list(url, term)
  noko = noko_for(url)
  noko.css('a.depute').each do |a|
    data = {
      id:         a.attr('data-siege'),
      name:       a.attr('data-nom'),
      image:      a.attr('data-photo').to_s.sub('.thumb50', ''),
      partylist:  a.attr('data-liste'),
      faction:    a.attr('data-bloc'),
      faction_id: a.attr('data-groupe_id'),
      area:       a.attr('data-region'),
      gender:     gender_from(a.attr('data-sexe')),
      term:       term,
      source:     url,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    ScraperWiki.save_sqlite(%i(id term), data)
  end
end

terms = {
  '2011' => 'http://majles.marsad.tn/fr/assemblee',
  '2014' => 'http://majles.marsad.tn/2014/fr/assemblee',
}

terms.each do |term, url|
  scrape_list(url, term)
end
