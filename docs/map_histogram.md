# Map and Histograms

## Map

A `Map` is a new datatype. It consists of a set of *key-value* pairs.

Try to make one:

- `val myMap:Map[String,Int] = Map("one" -> 1, "two" -> 2)`
- `val spanishNumbers:Map[Int,String] = Map(1 -> "uno", 2 -> "dos", 3 -> "tres")`

You can access the *values* of a `Map` with their *keys*.

- `myMap("two") == 2`
- `spanishNumbers(1) == "uno"`

Make a map named `aScore` of the numbers 1-20 in some language you know. Start with:

`val aScore:Map[Int,String] = `

(You may want to start with 1-5, to make the inevitable typos easier to spot.)

Use this as a reference tool by looking up numbers in that language.

## .groupBy

Maps are notoriously difficult to write by hand. Usually we generate them programmatically. 

`.groupBy` is a command that does this:

    val s:String = "abbcccddddeeeee"
    val vc:Vector[Char] = s.toVector
    val charMap:Map[Char,Vector[Char]] = vc.groupBy(c => c)

See what the possible keys are:

    charMap.keys

See what the possible values are:

	charMap.values

Get the value for a key:

    charMap('c')

Since the *values* you get from `.groupBy` are `Vector`s, you can get their size:

   charMap('c').size
   charMap('d').size

## Histogram

A Histogram ( see <https://en.wikipedia.org/wiki/Histogram> ) is "an accurate representation of the distribution of numerical data."

Let's make one:

```
val s:String = "abbcccddddeeeee"
val vc:Vector[Char] = s.toVector
val charMap:Map[Char,Vector[Char]] = vc.groupBy(c => c)
val quantMap = charMap.map(m => (m._1, m._2.size))
val mapVec:Vector[(Char, Int)] = quantMap.toVector
val sortedVec = mapVec.sortBy(_._2)
```









