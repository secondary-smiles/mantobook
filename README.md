# mantobook

Repo for [this blog post](https://frog.ski/blog/all-the-manpages).

A collection of all the manpages on my computer and how I got them.

- `mantobook.sh` - the script I used to create this repo
- `man` - file dump of all the manpages
- `man/{1..8}` - each folder contains every single manpage from the corresponding section. E.g. `man/1/ls.html` is the same as `man 1 ls`
- `man/comb` - contains the gzip'd *comb*inations of every manpage from the corresponding section. `man/comb/3.html` is every single manpage in section 3
- `man/intros` - the separated intro page for each section so that it can be prepended to the `comb` files.
