package codegen

import "core:strings"

Var :: []string

Start :: struct {
  var: Var,
  name: string,
  index: string,
  reversed_index: string,
}

WriteEntry :: struct {
  var: Var,
  lit: string,
}

SeparatorRule :: enum { NONE, BETWEEN, END }

Write :: struct {
  before: string,
  after:  string,
  vars: []WriteEntry,
  newline: bool,
  separator: SeparatorRule,
}

End :: struct{}

Directive :: union #no_nil { Start, Write, End }

delete_directives :: proc(dirs: []Directive) {
  for dir in dirs {
    switch d in dir {
      case Start:
        delete(d.var)
      case Write:
        for v in d.vars {
          delete(v.var)
        }
        delete(d.vars)
      case End:
    }
  }
  delete(dirs)
}

parse_template :: proc(template, prefix: string) -> ([]Directive, bool) {
  lines := strings.split_lines(template)
  defer delete(lines)

  directives := make([dynamic]Directive)

  for line in lines {
    i := strings.index(line, prefix)
    if i == -1 {
      append(&directives, Write{ line, {}, {}, true, {} })
      continue
    }

    literal := line[0:i]
    directive := strings.trim_space(line[i + len(prefix):])
    
    space := strings.index_byte(directive, ' ')
    if space == -1 do space = len(directive)
    word := directive[0:space]

    switch word {
      case "":
        continue
      case "l", "w", "s", "f":
        rule: SeparatorRule
        if word == "s" {
          rule = SeparatorRule.BETWEEN;
        } else if word == "f" {
          rule = SeparatorRule.END;
        }

        // write
        next := directive[2:] if len(directive) > 1 else {}
        index := strings.index(next, "${")
        if index == -1 {
          append(&directives, Write{ literal, next, {}, word == "l", rule })
          continue
        }

        first := next[0:index]

        entries := make([dynamic]WriteEntry)
        for index > -1 {
          end := strings.index(next[index + 2:], "}")
          if end == -1 {
            for entry in entries {
              delete(entry.var)
            }
            delete(entries)
            delete_directives(directives[:])
            return ---, false
          }

          var := strings.split(strings.trim_space(next[index + 2:index + 2 + end]), ".")
          
          next = next[index + 2 + end + 1:]
          index = strings.index(next, "${")
          lit := next
          if index != -1 do lit = next[0:index]

          append(&entries, WriteEntry{ var, lit })
        }

        append(&directives, Write{ literal, first, entries[:], word == "l", rule })
      case "e":
        // end
        if strings.trim_space(literal) != {} do append(&directives, Write{ literal, {}, {}, true, {} })
        append(&directives, End{})
      case "d":
        // delete
        continue
      case:
        // start
        var := strings.split(word, ".")

        name := var[len(var) - 1]
        if len(directive) > space {
          name = directive[space + 1:]
          space := strings.index_byte(name, ' ')
          if (space != -1) do name = name[:space]
        }

        index := ""
        if len(directive) > space + 1 + len(name) {
          index = directive[space + 1 + len(name) + 1:]
          space := strings.index_byte(index, ' ')
          if (space != -1) do index = index[:space]
        }

        reversed_index := ""
        if len(directive) > space + 1 + len(name) + 1 + len(index) {
          reversed_index = directive[space + 1 + len(name) + 1 + len(index) + 1:]
          space := strings.index_byte(reversed_index, ' ')
          if (space != -1) do reversed_index = reversed_index[:space]
        }

        if strings.trim_space(literal) != {} do append(&directives, Write{ literal, {}, {}, true, {} })
        append(&directives, Start{ var, name, index, reversed_index })
    }
  }

  return directives[:], true
}
