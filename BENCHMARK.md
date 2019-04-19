Results of `rake:benchmark` on ruby 2.6.2p47 (2019-03-13 revision 67232) [x86_64-darwin18]

```
Counting non-letters

CharacterSet#count_in: 12253693.8 i/s
        String#count:  1737741.7 i/s - 7.05x  slower
```
```
Detecting non-whitespace

 CharacterSet#cover?: 14058351.9 i/s
       Regexp#match?:  7907608.1 i/s - 1.78x  slower
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

CharacterSet#keep_in:  2740888.6 i/s
         String#gsub:   248584.4 i/s - 11.03x  slower
```
```
Extracting emoji

CharacterSet#keep_in:  1752397.8 i/s
         String#gsub:   225501.9 i/s - 7.77x  slower
```
```
Extracting emoji to an Array

   CharacterSet#scan:  2579030.8 i/s
         String#scan:   545107.0 i/s - 4.73x  slower
```
```
Detecting whitespace

CharacterSet#used_by?: 13847689.0 i/s
       Regexp#match?:  7533275.2 i/s - 1.84x  slower
```
```
Detecting emoji in a large string

CharacterSet#used_by?:   246527.7 i/s
       Regexp#match?:    92956.5 i/s - 2.65x  slower
```
