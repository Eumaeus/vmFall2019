## Notes on Digital Editions with Scala and CITE

Some steps toward a good digital edition:

- Make a citable edition
- Validate citation counts.
- Validate punctuation and character-set.
- Validate vocabulary!
- Tokenized exemplars.
- Lower-cased analytical exemplar.
- Allowed punctuation.
- 2 dictionaries
- Track complexity: words / periods, commas / period

## Sample Scala Code

The necessary libraries for the following examples are:

~~~ scala
import scala.io.Source
import java.io._
import edu.holycross.shot.scm._
import edu.holycross.shot.cite._
import edu.holycross.shot.ohco2._
~~~

### Print a corpus to the Console

`for (n <- corpus.nodes) println(s"${n.urn}\t${n.text}")`

### Tokenize a String

~~~ scala
val splitters:String = "[;., ?]"

def tokenizeString(str:String, splitters:String):Vector[String] = { 
	val tokenizedString:Array[String] = str.split(splitters)
	val withBlanksRemoved:Array[String] = tokenizedString.filter(_.size > 0)
	val returnVector:Vector[String] = withBlanksRemoved.toVector
	returnVector
}
~~~

### Tokenize a CitableNode

Given a CITE `CitableNode` and a regular expression string defining the tokenization, return a Vector of citable nodes with Exemplar-level URNs identifying each token.

~~~ scala
def tokenizeCtsNode(node:CitableNode, splitters:String, exemplarID:String = "token"):Vector[CitableNode] = {
	try {
		val editionUrn:CtsUrn = node.urn.dropPassage

		// Check that the URN is at the Version level
		if ( editionUrn.exemplarOption != None) {
			throw new Exception(s"The text cannot already be an exemplar! (${editionUrn})")
		}
		// If we get here, we're fine
		val exemplarUrn:CtsUrn = editionUrn.addExemplar(exemplarID)
		val editionCitation:String = node.urn.passageComponent
		val passage:String = node.text
		val tokens:Vector[String] = tokenizeString(passage, splitters)
		val tokenizedNodes:Vector[CitableNode] = {
			tokens.zipWithIndex.map{ case (n, i) => {
				val newUrn:CtsUrn = CtsUrn(s"${exemplarUrn}${editionCitation}.${i}")
				val newNode:CitableNode = CitableNode(newUrn, n)
				newNode
			}}.toVector	
		}
		tokenizedNodes
	} catch {
		case e:Exception => throw new Exception(s"${e}")
	}
}
~~~

### Tokenize a Corpus

This makes analytical exemplars.

~~~ scala
def tokenizeCorpus(c:Corpus, splitters:String, exemplarID:String = "token"):Corpus = {
	val nodeVector:Vector[CitableNode] = c.nodes.map( n => tokenizeCtsNode(n, splitters, exemplarID)).flatten
	val newCorpus:Corpus = Corpus(nodeVector)
	newCorpus
}
~~~

### Generate a new Edition from an Exemplar

Use case: You have an Edition, which you tokenize for the purpose of spell-checking or some other validation where you want to address individual tokens by URN. When the exemplar passes validation, you  can reassemble it into an new, validated Edition.

~~~ scala
def editionFromExemplar(c:Corpus, versionId:String):Corpus = {
	val versionUrns:Vector[CtsUrn] = c.nodes.map(_.urn.collapsePassageBy(1)).distinct
	val versionVector:Vector[CitableNode] = {
		versionUrns.map( u => {
			val passageTokens:Corpus = c ~~ u	
			val newVersionUrn:CtsUrn = u.dropVersion.addVersion(versionId)
			val newPassage:String = {
				passageTokens.nodes.map(_.text).mkString(" ")
			}
			CitableNode(newVersionUrn, newPassage)
		})
	}
	Corpus(versionVector)
}
~~~

Generate CEX with: `corpus.cex("#")`

### Print a string to a file

~~~ scala
def saveString(s:String, filePath:String):Unit = {
	val pw = new PrintWriter(new File(filePath))
	for (line <- s.lines){
		pw.append(line)
		pw.append("\n")
	}
	pw.close
}
~~~

### Make a Spellchecker

~~~ scala
def loadWordList(filepath:String):Vector[String] = {
	val lexData:Vector[String] = Source.fromFile(filepath).getLines.toVector
	lexData
}

val baseLexicon:Vector[String] = loadWordList("data/words.txt")
val customLexicon:Vector[String] = loadWordList("data/mywords.txt")

/* Returns a Corpus containing only citable nodes with words not present */
/* This version assumes the input Corpus is tokenized… one word per citable node. */
/* Obviously a full-fledged program should check for this somehow. */
/* This is case-sensitive! */

def spellCheck(corp:Corpus, lex:Vector[String]):Corpus = {
	val badWordCorpus:Corpus = {
		val badWordVec:Vector[CitableNode] = corp.nodes.filter( n => {
			lex.contains(n.text) == false
		}).toVector
		Corpus(badWordVec)
	}	
	badWordCorpus
}
~~~

### Undo words in all-caps, making them title-case

`"JESUS".toLowerCase.capitalize`

More elaborately:

~~~ scala
def fixAllCaps(s:String):String = {
	val matcher = "[A-Z]+".r
	val gotMatch:Option[String] = matcher.findFirstIn(s)		
	val returnString:String = {
		gotMatch match {
			case Some(m) => {
				if (s == m) { s.toLowerCase.capitalize }
				else { s }
			}
			case None => s
		}
	}
	returnString
}
~~~

### (In)validate a String (punctuation and character-set)

~~~ scala
// returns a (possibly empty) vector of invalid characters
def invalidateString(s:String):Vector[Char] = {
	val validChars = """[0-9A-Za-z.,;?:'" )(!]""".r 
~~~
~~~ scala
	// break above to re-sort-out Markdown's code parsing
	val charVector:Vector[Char] = s.toVector
	val invalidChars:Vector[Char] = charVector.filter(c => {
		validChars.findAllIn(c.toString).size == 0	
	})
	invalidChars
}

// returns either None, or Some(CitableNode) where the .urn is the urn 
// and the .text consists only of invalid chars
def invalidateCitableNode(n:CitableNode):Option[CitableNode] = {
	val text:String = n.text
	val invalidChars:Vector[Char] = invalidateString(text)
	invalidChars.size match {
		case s if (s > 0) => {
			val invalidCharString:String = invalidChars.map(c => {
				val newString = s""""${c}""""
				newString
			}).mkString(",")
			Some(CitableNode(n.urn, invalidCharString))
		}
		case _ => None
	}			
}

def invalidateCorpus(c:Corpus):Option[Corpus] = {
	val invalidNodeOptions:Vector[Option[CitableNode]] = c.nodes.map( n => {
		invalidateCitableNode(n)
	})
	val invalidNodes:Vector[CitableNode] = invalidNodeOptions.filter( n => {
		n != None
	}).map( sn => sn.get )

	if ( invalidNodes.size > 0 ) Some(Corpus(invalidNodes)) else None
}
~~~

### Chunk a Text

For reference:

~~~ scala
 val matthewUrn = CtsUrn("urn:cts:greekLit:tlg0031.tlg001.fu_kjv:")
 val markUrn = CtsUrn("urn:cts:greekLit:tlg0031.tlg002.fu_kjv:")
 val lukeUrn = CtsUrn("urn:cts:greekLit:tlg0031.tlg003.fu_kjv:")
 val johnUrn = CtsUrn("urn:cts:greekLit:tlg0031.tlg004.fu_kjv:")
~~~

Chunk a text by citation-level, getting a vector of CTS URNs. That is, if a text is cited like `1.1`, *e.g.* chapter and verse, get N corpora, one containing each chapter:

~~~ scala
def chunkByCitationLevel(corpus, thisText:CtsUrn, level:Int):Vector[CtsUrn] = {
	val allReff:Vector[CtsUrn] = corpus.validReff(thisText)
	// we only want passages that are at least N levels deep!
	val filteredForDepth:Vector[CtsUrn] = {
		allReff.filter(r => { 
			r.citationDepth.filter(_ >= level ).size > 0
		})
	}
	// Drop the level of all URNs to N, then just keep the unique ones.
	val chunkedUrns:Vector[CtsUrn] = filteredForDepth.map(_.collapsePassageTo(level)).distinct
	chunkedUrns // return the vector!
}

val testChunkByCitationLevel:Vector[CtsUrn] = chunkByCitationLevel(corpus, johnUrn, 1) 
// should equal 21 books
~~~

Chunk a text into N even pieces, getting a vector of CTS URNs:

~~~ scala
def chunkIntoPieces(corpus:Corpus, thisText:CtsUrn, numChunks:Int):Vector[CtsUrn] = {
	val allReff:Vector[CtsUrn] = corpus.validReff(thisText)
	val chunkSize:Int = allReff.size / numChunks
	// divide it into `numChunks` groups, with the last possibly having fewer members
	val groupVectors:Vector[Vector[CtsUrn]] = allReff.grouped(chunkSize).toVector
	// We don't want chunks, but a single-level vector of URNs
	val urnVector:Vector[CtsUrn] = {
		groupVectors.map(v => {
			val firstUrn:CtsUrn = v.head
			val lastUrn:CtsUrn = v.last
			val endPassage:String = lastUrn.passageComponent	
			val rangeUrn:CtsUrn = CtsUrn(s"${firstUrn}-${endPassage}")
			rangeUrn
		})
	}
	urnVector
}

val testChunkIntoPieces:Vector[CtsUrn] = chunkIntoPieces(corpus, johnUrn, 110) 
// should have size of 8
~~~

Get a slice of a text, N passages long, starting at index I (returns a range-CTS URN). This would be useful for doing a "rolling" analysis through a text.

~~~ scala
def sliceText(corpus:Corpus, thisText:CtsUrn, index:Int, numPassages:Int):CtsUrn = {
	val allReff:Vector[CtsUrn] = corpus.validReff(thisText)
	// don't forget that index starts at zero!
	val endIndex:Int = index + numPassages
	val slicedReff:Vector[CtsUrn] = allReff.slice(index, endIndex)	
	val firstUrn:CtsUrn = slicedReff.head
	val endPassage:String = slicedReff.last.passageComponent
	val rangeUrn:CtsUrn = CtsUrn(s"${firstUrn}-${endPassage}")
	rangeUrn
}

val testSliceText1:CtsUrn = sliceText(corpus, johnUrn, 0, 4)
// should be: urn:cts:greekLit:tlg0031.tlg004.fu_kjv:head-1.3
val testSliceText2:CtsUrn = sliceText(corpus, johnUrn, 876, 4)
// should be: urn:cts:greekLit:tlg0031.tlg004.fu_kjv:21.22-21.25
~~~

## Example of an Analysis

Question:

> Does John's language get more complex as the work progresses? 

As a starting point, we can derive a ration of `words / period`, taking one book at a time.

For this analysis, we can count periods (full-stops), semicolons, and question-marks as equivalent. 

Building on the above methods, we can start with counting word-tokens and full-stops (periods) in a single citable node.

### Count Words in a Citable Node

~~~ scala
def countEnglishWordsInNode(passage:CitableNode):Int = {
	val splitters:String = "[;., :?()]"
	val englishWords:Vector[String] = tokenizeString(passage.text, splitters)
	val howManyWords:Int = englishWords.size
	howManyWords
}
~~~

### Count Characters in a Citable Node

`chars` is a string of the characters you want to count. So if you want to count just commas, `","`, but if you want commas and semicolons, `",;"`:

~~~ scala
def countSomeCharsInNode(passage:CitableNode, chars:String):Int = {
	val matcher:scala.util.matching.Regex = s"[${chars}]".r
	val howMany:Int = matcher.findAllIn(passage.text).size
	howMany
}
~~~

### Summation Across a Corpus

Now we can throw a bunch of citable nodes at the methods we defined above, and sum their results:

~~~ scala
def sumEnglishWordsInCorpus(corpus:Corpus):Int = {
	// For summing, we need, not a vector of CitableNodes, but a vector of Ints,
	// …that is, we want to replace CitableNodes with their word-counts
	val countVec:Vector[Int] = corpus.nodes.map(n => countEnglishWordsInNode(n))
	// Now we can just do a quick summation with the awesome "foldLeft" method
	val count:Int = countVec.reduceLeft( _ + _ )
	count
}

def sumSomeCharsInCorpus(corpus:Corpus, chars:String):Int = {
	// For summing, we need, not a vector of CitableNodes, but a vector of Ints,
	// …that is, we want to replace CitableNodes with their<p></p> counts
	val countVec:Vector[Int] = corpus.nodes.map(n => countSomeCharsInNode(n, chars))
	// Now we can just do a quick summation with the awesome "foldLeft" method
	val count:Int = countVec.reduceLeft( _ + _ )
	count
}
~~~

### Ratios

So we want `words / punctuation` for a corpus. Easy:

~~~ scala
def wordsPerChar(corpus:Corpus, chars:String):Double = {
	val wordCount:Int = sumEnglishWordsInCorpus(corpus)
	val charCount:Int = sumSomeCharsInCorpus(corpus, chars)
	// guard against divide-by-zero error!
	val wpc:Double = {
		if (charCount > 0) { wordCount / charCount } else { 0 }
	}
	wpc
}

val wpc:Double = wordsPerChar(corpus, ".;") // counts semicolons -or- periods

~~~

### Chunked Analysis

Let's see "complexity of language" (by the tentative measure of "words per period-or-semicolon") one Chapter of John at a time. The steps are:

1. Do a `chunkByCitationLevel` at level = 1 with a URN identifying John to get a `Vector[CtsUrn]`
1. Map it…

~~~ scala
val johnChapterUrns:Vector[CtsUrn] = chunkByCitationLevel(corpus, johnUrn, 1)
val johnComplexityMap:Vector[Double] = johnChapterUrns.map(c => wordsPerChar( (corpus ~~ c), ";.?!" ))
// If you want the average…
val johnComplexityMapAverage:Double = johnComplexityMap.reduceLeft(_ + _) / johnComplexityMap.size
~~~






