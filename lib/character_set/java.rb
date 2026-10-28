# frozen_string_literal: true

require 'java'
require_relative 'character_set.jar'

JRuby::Util.load_ext('org.jaynetics.characterset.CharacterSetService')
