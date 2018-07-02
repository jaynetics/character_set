Results of `rake:benchmark` on ruby 2.6.0preview1 (2018-02-24 trunk 62554) [x86_64-darwin17]

```
Detecting non-whitespace

 CharacterSet#cover?: 13244577.7 i/s
       Regexp#match?:  8027017.5 i/s - 1.65x  slower
```
```
Detecting non-letters

 CharacterSet#cover?: 13082940.8 i/s
       Regexp#match?:  5372589.2 i/s - 2.44x  slower
```
```
Removing whitespace

CharacterSet#delete_in:   389315.6 i/s
         String#gsub:   223773.5 i/s - 1.74x  slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:   470239.3 i/s
         String#gsub:   278679.4 i/s - 1.69x  slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  1138461.0 i/s
         String#gsub:   235287.4 i/s - 4.84x  slower
```
```
Extracting emoji

CharacterSet#keep_in:  1474472.0 i/s
         String#gsub:   212269.6 i/s - 6.95x  slower
```
```
Detecting whitespace

CharacterSet#used_by?: 13063108.7 i/s
       Regexp#match?:  7215075.0 i/s - 1.81x  slower
```
```
Detecting emoji in a large string

CharacterSet#used_by?:   246527.7 i/s
       Regexp#match?:    92956.5 i/s - 2.65x  slower
```
