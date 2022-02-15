Results of `rake:benchmark` on ruby 3.2.0dev (2022-02-14T14:35:54Z master 26187a8520) [arm64-darwin21]

```
Counting non-letters

CharacterSet#count_in: 14794607.9 i/s
        String#count:  3875939.3 i/s - 3.82x slower
```
```
Detecting non-whitespace

 CharacterSet#cover?: 17448329.0 i/s
       Regexp#match?: 13089358.1 i/s - 1.33x slower
```
```
Detecting non-letters

 CharacterSet#cover?: 17565596.9 i/s
       Regexp#match?:  7951108.0 i/s - 2.21x slower
```
```
Removing whitespace

CharacterSet#delete_in:  6346527.5 i/s
         String#gsub:   213181.0 i/s - 29.77x slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:  6019275.2 i/s
         String#gsub:   318986.4 i/s - 18.87x slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  7651109.7 i/s
         String#gsub:   208996.1 i/s - 36.61x slower
```
```
Extracting emoji

CharacterSet#keep_in:  7272115.3 i/s
         String#gsub:   179505.1 i/s - 40.51x slower
```
```
Extracting emoji to an Array

   CharacterSet#scan:  2978285.0 i/s
         String#scan:   865793.8 i/s - 3.44x slower
```
```
Detecting whitespace

CharacterSet#used_by?: 17292338.4 i/s
       Regexp#match?: 11705563.9 i/s - 1.48x slower
```
```
Detecting emoji in a large string

CharacterSet#used_by?:   340444.1 i/s
       Regexp#match?:   180549.8 i/s - 1.89x slower
```
```
Adding entries

    CharacterSet#add:  4951781.4 i/s
       SortedSet#add:  1019637.9 i/s - 4.86x slower
```
```
Removing entries

 CharacterSet#delete:  5006337.6 i/s
    SortedSet#delete:  3922752.2 i/s - same-ish
```
```
Merging entries

  CharacterSet#merge:      661.8 i/s
     SortedSet#merge:        3.9 i/s - 167.82x slower
```
```
Getting the min and max

 CharacterSet#minmax:  1212462.2 i/s
    SortedSet#minmax:      844.4 i/s - 1435.93x slower
```
