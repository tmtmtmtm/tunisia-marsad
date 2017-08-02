#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MemberLink < Scraped::HTML
  field :id do
    noko.attr('data-siege')
  end

  field :name do
    noko.attr('data-nom')
  end

  field :image do
    URI.join(url, URI.escape(noko.attr('data-photo').to_s.sub('.thumb50', ''))).to_s
  end

  field :partylist do
    noko.attr('data-liste')
  end

  field :faction do
    noko.attr('data-bloc')
  end

  field :faction_id do
    noko.attr('data-groupe_id')
  end

  field :area do
    noko.attr('data-region')
  end

  field :gender do
    gender = noko.attr('data-sexe')
    return if gender.to_s.empty?
    return 'male' if gender == 'Hommes'
    return 'female' if gender == 'Femmes'
    raise "Unknown gender: #{gender}"
  end

  field :source do
    noko.attr('href')
  end
end

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
    ScraperWiki.save_sqlite(%i[id term], data)
  end
end
