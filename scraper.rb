#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

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

def scrape_list(url)
  noko = noko_for(url)
  noko.css('a.depute').each do |a|
    data = { 
      id: a.attr('data-siege'),
      name: a.attr('data-nom'),
      image: a.attr('data-photo').to_s.sub('.thumb50',''),
      partylist: a.attr('data-liste'),
      faction: a.attr('data-bloc'),
      faction_id: a.attr('data-groupe_id'),
      area: a.attr('data-region'),
      gender: gender_from(a.attr('sexe')),
      term: '2014',
      source: url,
    }
    data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
    puts data
    # ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape_list('http://majles.marsad.tn/2014/fr/assemblee')
