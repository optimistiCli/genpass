# genpass
## Handy CLI password generator
```
Usage:
  genpass.sh [-hlLuUdDsSXaAq] [-x <character list>] [-n <number>] [<length>]

  Generates random password consisting of exactly <length> chars including
  by default capital and lowercase English letters and digits. If no length 
  is provided it defaults to 10 chars. Minimum length is 6.

Options:
  h - Print usage and exit
  l - Use lower case letters (default)
  L - Do NOT use lower case letters
  u - Use upper case letters (default)
  U - Do NOT use upper case letters
  d - Use digits (default)
  D - Do NOT use digits
  s - Use special characters !$%@#
  S - Do NOT use special characters (default)
  x - Use characters form the list - do it at your own risk!
  X - Disable and override the '-x' option
  a - Password must conain chars of all classes
  A - Same as -a but treat special and extra chars as one class (faster)
  n - Generate number of passwords (default is 1)
  q - Do not output anything but the password(s)

Please note that -x option might not be safe. It's better to enforce the use 
of -X in a hostile environment.
```
