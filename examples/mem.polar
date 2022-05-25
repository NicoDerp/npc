
// Reserve 1 byte for a, b and c
memory a 1 end
memory b 1 end
memory c 1 end

// Write 79, 60 and 255 to a, b and c
a 79 .
b 60 .
c 255 .

// Read the values and print them one by one
a , dump
b , dump
c , dump


