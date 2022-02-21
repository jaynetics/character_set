Results of `rake:benchmark` on ruby 3.2.0dev (2022-02-14T14:35:54Z master 26187a8520) [arm64-darwin21]

```
Counting non-letters

CharacterSet#count_in: 14627506.2 i/s
        String#count:  3859777.0 i/s - 3.79x slower
```
```
Detecting non-whitespace

 CharacterSet#cover?: 17241902.8 i/s
       Regexp#match?: 12971122.6 i/s - 1.33x slower
```
```
Detecting non-letters

 CharacterSet#cover?: 17243472.3 i/s
       Regexp#match?:  7957626.9 i/s - 2.17x slower
```
```
Removing ASCII whitespace

CharacterSet#delete_in:  6190975.7 i/s
           String#tr:  4722716.6 i/s - 1.31x slower
         String#gsub:   214239.5 i/s - 28.90x slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:  5890471.8 i/s
           String#tr:   348506.8 i/s - 16.90x slower
         String#gsub:   318268.3 i/s - 18.51x slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  7396898.0 i/s
         String#gsub:   208809.7 i/s - 35.42x slower
           String#tr:       13.1 i/s - 564682.50x slower
```
```
Keeping only emoji

CharacterSet#keep_in:  7022741.1 i/s
         String#gsub:   180939.6 i/s - 38.81x slower
           String#tr:       13.1 i/s - 536724.50x slower
```
```
Extracting emoji to an Array

   CharacterSet#scan:  3023176.8 i/s
         String#scan:   893225.8 i/s - 3.38x slower
```
```
Detecting whitespace

CharacterSet#used_by?: 17284025.9 i/s
       Regexp#match?: 11847064.5 i/s - 1.46x slower
```
```
Detecting emoji in a large string

CharacterSet#used_by?:   341386.1 i/s
       Regexp#match?:   183121.6 i/s - 1.86x slower
```
```
Adding entries

    CharacterSet#add:  4989762.3 i/s
       SortedSet#add:  1157911.7 i/s - 4.31x slower
```
```
Removing entries

 CharacterSet#delete:  4996703.6 i/s
    SortedSet#delete:  4177401.5 i/s - same-ish
```
```
Merging entries

  CharacterSet#merge:      666.7 i/s
     SortedSet#merge:        4.0 i/s - 167.84x slower
```
```
Getting the min and max

 CharacterSet#minmax:  1596470.9 i/s
    SortedSet#minmax:      866.4 i/s - 1842.74x slower
```
