# npc

## Nico's Polar Compiler

Polar is a stack-based concatinative language.
That means it also uses reverse polish notation.
You use only the stack and simple memory use, no variables.

Polar is planned to be
- [x] Turing-complete
- [ ] Self-hosted

Even though i could implement variables in the future, I choose to not have variables. I wan't Polar to not be advanced and have many ways to do something. If something can be done in Polar without variables, I would want it that way.

## Examples

Simple program that prints the numbers from 0 to 99 in ascending order:

```polar
fun main in
  100 0 while 2dup > do
    dup dump
    1 +
  end drop drop
end
```

## Usage


