
// Reserve space for 3 characters
memory txt 3 end

// Write 'abc' into the memory (97, 98, 99)
txt 0 + 97 .
txt 1 + 98 .
txt 2 + 99 .

// Newline at the end
txt 3 + 10 .

4 txt 1 1 syscall3 // Write to stdout

// Add 1 to all characters
0 while dup 3 < do
  // Duplicate txt+index to save one for later
  dup txt + dup

  // Read the character and increment it
  , 1 +

  // Store it
  .

  // Increment the index
  1 +
end drop // Drop the index

4 txt 1 1 syscall3 // Write to stdout

