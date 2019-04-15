Results of `rake:benchmark` on ruby 2.6.2p47 (2019-03-13 revision 67232) [x86_64-darwin18]

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

CharacterSet#delete_in:  2623946.1 i/s
         String#gsub:   244942.3 i/s - 10.71x  slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:  1762445.6 i/s
         String#gsub:   291634.8 i/s - 6.04x  slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  2765669.2 i/s
         String#gsub:   254172.7 i/s - 10.88x  slower
```
```
Extracting emoji

CharacterSet#keep_in:  1758432.6 i/s
         String#gsub:   229069.6 i/s - 7.68x  slower
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
