#!/usr/bin/ruby

class EuclideanText
  # Words that are filtered out of histograms
  @@remove = ['said', 'put', 'much', '', 'no', 'where', 'do', 'how', 'through', 'were', 'while', \
    'my', 'why', 'many','not', 'often', 'did', 'still', 'because', 'from', 'such', 'should','who', \
    'each', 'none', 'between', 'like', 'his', 'her', 'him', 'her', 'himself', 'herself', 'you', 'too', \
     'very', 'but','be', 'into','they', 'would', 'will','us', 'some', 'could', 'so', 'what', 'also', \
      'them', 'then','we', 'or', 'by', 'are', 'those', 'this', 'about', 'was', 'had', 'when', 'which', \
       'of', 'to', 'if', 'it', 'its', 'a', 'with', 'the', 'and', 'in', 'at', 'have', 'that', 'is', 'an', \
        'for', 'on', 'has', 'as', 'been', 'The', 'our']

  def self.clean(input)
    @@remove.each do |item|
      input.delete(item)
    end  
  
    input
  end

  def self.read_article(file_name)
    input = []
    File.read(file_name).each do |item| 
      item.split(' ').each do |item1|
        #Make everything lowercase without punctuation
        input.push(item1.downcase.delete('\'\",-.:;()?'))
      end
    end    
    input
  end
  
  #Convert a word-array into a histogram of words as keys and the
  #number of times they occur as values.  Sorted in descending order.
  def self.histogram(text_array)
    histo = {}
    
    text_array.each do |item|
      unless histo[item]
        histo[item] = 1
      else
        histo[item] += 1         
      end      
    end
    
    histo.sort {|a,b| b[1] <=> a[1] }
  end
  
  def self.read_to_histogram(file_name)
    article1 = read_article(file_name)
    article1 = clean(article1)
    histo1 = histogram(article1)
  end
  
  #Calculate the Euclidean distance between two word histograms.
  #Then scale it by the ratio of words not fount to the ratio of found.
  def self.histogram_distance(input1, input2)
    histo1 = input1.clone
    histo2 = input2.clone
    
    #The sort operation converted the has to an array-of-arrays.
    #Flatten them out so that if entry i is a word then i + 1 is a value
    histo1.flatten!
    histo2.flatten!
    
    #average word count
    word_count = (histo1.size + histo2.size)/2
    
    #Sum of squares
    sum = 0
    #Total words that were in both articles
    found = 0
    #Total words that were in one or the other
    not_found = 0
    
    
    histo1.each_index do |x|
      next if x % 2 == 1
      
      y = histo2.index(histo1[x])
      #Found a match in the second histogram
      unless y.nil?
        #Calculate the square of the difference of the occurences
        diff = histo1[x+1] - histo2[y+1]
        sum += diff**2
        found += 1
        
        #Remove the entry and value from the second histogram
        histo2[y] = nil
        histo2[y+1] = nil
      else
        #No match for this word.  Add it to the difference anyway.
        not_found += 1
        diff = histo1[x+1]
        sum += diff**2
      end
      
    end
    
    #Compact the second histogram so it contains only words not found in the first
    histo2.compact!
    
    histo2.each_index do |y|
      next if y % 2 == 1
      
      #These should be all the entries that did NOT match the first time through
      not_found += 1
      diff = histo2[y+1]
      sum += diff**2
    end

    #Normalize the difference
    # found_normal =  1.0 - found.to_f/word_count.to_f
    # not_found_normal = 1.0 - not_found.to_f/word_count.to_f

    #Ratio of not found words to found words
    difference =  not_found.to_f/found.to_f

    #Take the square root of the sum-of-squares and to get distance.  
    #The distance is scaled to be relative to the non-matched words ratio
    final = Math.sqrt(sum) * difference
  end
  
end