Results of `rake:benchmark` on ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin19]

```
Counting non-letters

CharacterSet#count_in:  9472902.2 i/s
        String#count:  2221799.9 i/s - 4.26x slower
```
```
Detecting non-whitespace

 CharacterSet#cover?: 12388427.2 i/s
       Regexp#match?:  7901676.8 i/s - 1.57x slower
```
```
Detecting non-letters

 CharacterSet#cover?: 12263689.1 i/s
       Regexp#match?:  4940889.9 i/s - 2.48x slower
```
```
Removing whitespace

CharacterSet#delete_in:  2406722.6 i/s
         String#gsub:   235760.3 i/s - 10.21x slower
```
```
Removing whitespace, emoji and umlauts

CharacterSet#delete_in:  1653607.6 i/s
         String#gsub:   272782.9 i/s - 6.06x slower
```
```
Removing non-whitespace

CharacterSet#keep_in:  2671038.2 i/s
         String#gsub:   242551.0 i/s - 11.01x slower
```
```
Extracting emoji

CharacterSet#keep_in:  1726496.5 i/s
         String#gsub:   215609.2 i/s - 8.01x slower
```
```
Extracting emoji to an Array

   CharacterSet#scan:  2373856.1 i/s
         String#scan:   480000.5 i/s - 4.95x slower
```
```
Detecting whitespace

CharacterSet#used_by?: 11988328.7 i/s
       Regexp#match?:  6758146.8 i/s - 1.77x slower
```
```
Detecting emoji in a large string

CharacterSet#used_by?:   288223.3 i/s
       Regexp#match?:   102384.2 i/s - 2.82x slower
```
```
Adding entries

    CharacterSet#add:  2538251.2 i/s
       SortedSet#add:   443925.9 i/s - 5.72x slower
```
```
Removing entries

 CharacterSet#delete:  2487620.8 i/s
    SortedSet#delete:   628816.1 i/s - 3.96x slower
```
```
Merging entries

  CharacterSet#merge:      551.6 i/s
     SortedSet#merge:        1.4 i/s - 393.59x slower
```
```
Getting the min and max

 CharacterSet#minmax:   636890.7 i/s
    SortedSet#minmax:      254.1 i/s - 2506.20x slower
```
