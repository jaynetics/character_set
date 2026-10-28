TESTED_ENCODINGS = [
  ::Encoding::ASCII_8BIT,
  ::Encoding::ISO8859_1,
  ::Encoding::SHIFT_JIS,
  ::Encoding::UTF_8,
  ::Encoding::UTF_16BE,
  ::Encoding::UTF_16LE,
  ::Encoding::UTF_32BE,
  ::Encoding::UTF_32LE,
  ::Encoding::WINDOWS_1251,
  ::Encoding::WINDOWS_1252,
]

NON_ASCII_ENCODING_SAMPLES = {
  'ISO-8859-1' => 'äü',
  'Windows-1251' => 'аб',
  'Windows-1252' => '€ü',
  'Shift_JIS' => 'あい',
  'EUC-JP' => 'äü',
  'UTF-16BE' => 'ä😋',
  'UTF-16LE' => 'ä😋',
  'UTF-32BE' => 'ä😋',
  'UTF-32LE' => 'ä😋',
}

# Overlong encoding, truncated character, surrogate, out-of-range codepoint,
# and an isolated continuation byte.
INVALID_UTF8_STRINGS = [
  "a\xC1\x80b", "\xE2\x82", "\xED\xA0\x80", "\xF4\x90\x80\x80", "\x80",
]
