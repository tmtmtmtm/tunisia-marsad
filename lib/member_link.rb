# frozen_string_literal: true
require 'scraped'

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
