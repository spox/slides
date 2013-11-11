# gio-slides

This is based off the Google io-2012-slides project. It does
a few things differently:

* Haml based templates
* Haml based slide generation
* JSON configuration of common elements
* Adds guards for regenerating on changes

## Usage

Create new branch based off `base` and run:

```
$ bundle install
$ bundle exec guard start -i
```

New slides go in the `content` directory. They will be name sorted
when built. The guard will generate the `output/index.html` file,
which should hopefully be the presentation. Yay!

## Notes

* Based entirely from: https://code.google.com/p/io-2012-slides/
* Sprinkled with: [haml](http://haml.info/), [sass](http://sass-lang.com/), and [guard](https://github.com/guard/guard)
* Repository: https://github.com/spox/slides