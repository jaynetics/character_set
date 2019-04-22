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

 CharacterSet#cover?: 13341301.6 i/s
       Regexp#match?:  5187453.3 i/s - 2.57x  slower
```
```
Removing whitespace

CharacterSet#delete_in:  2523184.0 i/s
         String#gsub:   225804.7 i/s - 11.17x  slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:  1712208.6 i/s
         String#gsub:   278508.8 i/s - 6.15x  slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  2760158.1 i/s
         String#gsub:   232797.7 i/s - 11.86x  slower
```
```
Extracting emoji

CharacterSet#keep_in:  1775758.8 i/s
         String#gsub:   217649.9 i/s - 8.16x  slower
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
```
Adding entries

    CharacterSet#add:  3102081.7 i/s
       SortedSet#add:  1897464.8 i/s - 1.63x  slower
```
```
Removing entries

 CharacterSet#delete:  3240924.1 i/s
    SortedSet#delete:  2887493.9 i/s - 1.12x  slower
```
```
Merging entries

  CharacterSet#merge:      536.8 i/s
     SortedSet#merge:       12.5 i/s - 42.78x  slower
```
```
Getting the min and max

 CharacterSet#minmax:  4111960.8 i/s
    SortedSet#minmax:      756.4 i/s - 5436.39x  slower
```
